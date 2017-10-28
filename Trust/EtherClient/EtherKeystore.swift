// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth
import Result
import KeychainSwift
import CryptoSwift

class EtherKeystore: Keystore {

    struct Keys {
        static let keychainKeyPrefix = "trustwallet"
        static let recentlyUsedAddress: String = "recentlyUsedAddress"
    }

    private let keychain: KeychainSwift
    let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]

    let gethKeyStorage: GethKeyStore

    public init(
        keychain: KeychainSwift = KeychainSwift(keyPrefix: Keys.keychainKeyPrefix),
        keyStoreSubfolder: String = "/keystore"
    ) {
        self.keychain = keychain
        self.gethKeyStorage = GethNewKeyStore(self.datadir + keyStoreSubfolder, GethLightScryptN, GethLightScryptP)
    }

    var hasAccounts: Bool {
        return !accounts.isEmpty
    }

    var recentlyUsedAccount: Account? {
        set {
            keychain.set(newValue?.address.address ?? "", forKey: Keys.recentlyUsedAddress)
        }
        get {
            let address = keychain.get(Keys.recentlyUsedAddress)
            return accounts.filter { $0.address.address == address }.first
        }
    }

    static var current: Account? {
        return EtherKeystore().recentlyUsedAccount
    }

    // Async
    func createAccount(with password: String, completion: @escaping (Result<Account, KeyStoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let account = self.createAccout(password: password)
            DispatchQueue.main.async {
                completion(.success(account))
            }
        }
    }

    func importKeystore(value: String, password: String, completion: @escaping (Result<Account, KeyStoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.importKeystore(value: value, password: password)
            DispatchQueue.main.async {
                switch result {
                case .success(let account):
                    completion(.success(account))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func createAccout(password: String) -> Account {
        let gethAccount = try! gethKeyStorage.newAccount(password)
        let account: Account = .from(account: gethAccount)
        let _ = setPassword(password, for: account)
        return account
    }

    func importKeystore(value: String, password: String) -> Result<Account, KeyStoreError> {
        let data = value.data(using: .utf8)
        do {
            //Check if this account already been imported
            let json = try JSONSerialization.jsonObject(with: data!, options: [])
            if let dict = json as? [String: AnyObject], let address = dict["address"] as? String {
                var error: NSError? = nil
                if gethKeyStorage.hasAddress(GethNewAddressFromHex(address.add0x, &error)) {
                    return (.failure(.duplicateAccount))
                }
            }

            let gethAccount = try gethKeyStorage.importKey(data, passphrase: password, newPassphrase: password)
            let account: Account = .from(account: gethAccount)
            let _ = setPassword(password, for: account)
            return (.success(account))
        } catch {
            return (.failure(.failedToImport(error)))
        }
    }

    func importPrivateKey() -> Account? {
        return nil
//        return Account(
//            address: ""
//        )
    }

    var accounts: [Account] {
        return self.gethAccounts.map { Account(address: Address(address: $0.getAddress().getHex())) }
    }

    var gethAccounts: [GethAccount] {
        var finalAccounts: [GethAccount] = []
        let allAccounts = gethKeyStorage.getAccounts()
        let size = allAccounts?.size() ?? 0

        for i in 0..<size {
            if let account = try! allAccounts?.get(i) {
                finalAccounts.append(account)
            }
        }

        return finalAccounts
    }

    func export(account: Account, password: String, newPassword: String) -> Result<String, KeyStoreError> {
        let result = exportData(account: account, password: password, newPassword: newPassword)
        switch result {
        case .success(let data):
            let string = String(data: data, encoding: .utf8) ?? ""
            return (.success(string))
        case .failure(let error):
            return (.failure(error))
        }
    }

    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeyStoreError> {
        let gethAccount = getGethAccount(for: account.address)
        do {
            let data = try gethKeyStorage.exportKey(gethAccount, passphrase: password, newPassphrase: newPassword)
            return (.success(data))
        } catch {
            return (.failure(.failedToDecryptKey))
        }
    }

    func delete(account: Account) -> Result<Void, KeyStoreError> {
        let gethAccount = getGethAccount(for: account.address)
        let password = getPassword(for: account)
        do {
            try gethKeyStorage.delete(gethAccount, passphrase: password)
            return (.success())
        } catch {
            return (.failure(.failedToDeleteAccount))
        }
    }

    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeyStoreError> {
        let gethAccount = getGethAccount(for: account.address)
        do {
            try gethKeyStorage.update(gethAccount, passphrase: password, newPassphrase: newPassword)
            return (.success())
        } catch {
            return (.failure(.failedToUpdatePassword))
        }
    }

    func signTransaction(
        _ signTransaction: SignTransaction
    ) -> Result<Data, KeyStoreError> {
        let gethAddress = GethNewAddressFromHex(signTransaction.address.address, nil)
        let transaction = GethNewTransaction(
            signTransaction.nonce,
            gethAddress,
            signTransaction.amount,
            signTransaction.speed.gasLimit,
            signTransaction.speed.gasPrice,
            signTransaction.data
        )
        let password = getPassword(for: signTransaction.account)

        let gethAccount = getGethAccount(for: signTransaction.account.address)

        do {
            try gethKeyStorage.unlock(gethAccount, passphrase: password)
            let signedTransaction = try gethKeyStorage.signTx(
                gethAccount,
                tx: transaction,
                chainID: signTransaction.chainID
            )
            let rlp = try signedTransaction.encodeRLP()
            return (.success(rlp))
        } catch {
            return (.failure(.failedToSignTransaction))
        }
    }

    func getPassword(for account: Account) -> String? {
        return keychain.get(account.address.address.lowercased())
    }

    @discardableResult
    func setPassword(_ password: String, for account: Account) -> Bool {
        return keychain.set(password, forKey: account.address.address.lowercased())
    }

    func getGethAccount(for address: Address) -> GethAccount {
        return gethAccounts.filter { Address(address: $0.getAddress().getHex()) == address }.first!
    }

    func convertPrivateKeyToKeystoreFile(privateKey: String, passphrase: String) -> Result<[String: Any], KeyStoreError> {
        let privateKeyBytes: [UInt8] = Array(Data(fromHexEncodedString: privateKey)!)
        let passphraseBytes: [UInt8] = Array(passphrase.utf8)
        let numberOfIterations = 262144
        do {
            // derive key
            let salt: [UInt8] = AES.randomIV(32)
            let derivedKey = try PKCS5.PBKDF2(password: passphraseBytes, salt: salt, iterations: numberOfIterations, variant: .sha256).calculate()

            // encrypt
            let iv: [UInt8] = AES.randomIV(AES.blockSize)
            let aes = try AES(key: Array(derivedKey[..<16]), blockMode: .CTR(iv: iv), padding: .pkcs7)
            let ciphertext = try aes.encrypt(privateKeyBytes)

            // calculate the mac
            let macData = Array(derivedKey[16...]) + ciphertext
            let mac = SHA3(variant: .keccak256).calculate(for: macData)

            /* convert to JSONv3 */

            // KDF params
            let kdfParams: [String: Any] = [
                "prf": "hmac-sha256",
                "c": numberOfIterations,
                "salt": salt.toHexString(),
                "dklen": 32,
            ]

            // cipher params
            let cipherParams: [String: String] = [
                "iv": iv.toHexString()
            ]

            // crypto struct (combines KDF and cipher params
            var cryptoStruct = [String: Any]()
            cryptoStruct["cipher"] = "aes-128-ctr"
            cryptoStruct["ciphertext"] = ciphertext.toHexString()
            cryptoStruct["cipherparams"] = cipherParams
            cryptoStruct["kdf"] = "pbkdf2"
            cryptoStruct["kdfparams"] = kdfParams
            cryptoStruct["mac"] = mac.toHexString()

            // encrypted key json v3
            let encryptedKeyJSONV3: [String: Any] = [
                "crypto": cryptoStruct,
                "version": 3,
                "id": "",
            ]

            return .success(encryptedKeyJSONV3)
        } catch {
            return .failure(KeyStoreError.failedToImportPrivateKey)
        }
    }
}

extension Account {
    static func from(account: GethAccount) -> Account {
        return Account(
            address: Address(address: account.getAddress().getHex())
        )
    }
}

extension Data {
    init?(fromHexEncodedString string: String) {
        // Convert 0 ... 9, a ... f, A ...F to their decimal value,
        // return nil for all other input characters
        func decodeNibble(u: UInt16) -> UInt8? {
            switch(u) {
            case 0x30 ... 0x39:
                return UInt8(u - 0x30)
            case 0x41 ... 0x46:
                return UInt8(u - 0x41 + 10)
            case 0x61 ... 0x66:
                return UInt8(u - 0x61 + 10)
            default:
                return nil
            }
        }
        
        self.init(capacity: string.utf16.count/2)
        var even = true
        var byte: UInt8 = 0
        for c in string.utf16 {
            guard let val = decodeNibble(u: c) else { return nil }
            if even {
                byte = val << 4
            } else {
                byte += val
                self.append(byte)
            }
            even = !even
        }
        guard even else { return nil }
    }
}
