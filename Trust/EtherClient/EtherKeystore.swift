// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import Result
import KeychainSwift
import CryptoSwift
import TrustKeystore

enum EtherKeystoreError: LocalizedError {
    case protectionDisabled
}

open class EtherKeystore: Keystore {

    struct Keys {
        static let recentlyUsedAddress: String = "recentlyUsedAddress"
    }

    private let keychain: KeychainSwift
    private let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let keyStore: KeyStore
    private let defaultKeychainAccess: KeychainSwiftAccessOptions = .accessibleWhenUnlockedThisDeviceOnly

    public init(
        keychain: KeychainSwift = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix),
        keyStoreSubfolder: String = "/keystore"
    ) throws {
        if !UIApplication.shared.isProtectedDataAvailable {
            throw EtherKeystoreError.protectionDisabled
        }

        let keydir = datadir + keyStoreSubfolder
        self.keychain = keychain
        self.keychain.synchronizable = false
        self.keyStore = try KeyStore(keydir: URL(fileURLWithPath: keydir))
    }

    var hasAccounts: Bool {
        return !accounts.isEmpty
    }

    var recentlyUsedAccount: Account? {
        set {
            keychain.set(newValue?.address.address ?? "", forKey: Keys.recentlyUsedAddress, withAccess: defaultKeychainAccess)
        }
        get {
            let address = keychain.get(Keys.recentlyUsedAddress)
            return accounts.filter { $0.address.address == address }.first
        }
    }

    static var current: Account? {
        do {
            return try EtherKeystore().recentlyUsedAccount
        } catch {
            return .none
        }
    }

    // Async
    @available(iOS 10.0, *)
    func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let account = self.createAccout(password: password)
            DispatchQueue.main.async {
                completion(.success(account))
            }
        }
    }

    func importWallet(type: ImportType, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        let newPassword = PasswordGenerator.generateRandom()
        switch type {
        case .keystore(let string, let password):
            importKeystore(
                value: string,
                password: password,
                newPassword: newPassword,
                completion: completion
            )
        case .privateKey(let privateKey):
            self.keystore(for: privateKey, password: newPassword) { result in
                switch result {
                case .success(let value):
                    self.importKeystore(
                        value: value,
                        password: newPassword,
                        newPassword: newPassword,
                        completion: completion
                    )
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func keystore(for privateKey: String, password: String, completion: @escaping (Result<String, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let keystore = self.convertPrivateKeyToKeystoreFile(
                privateKey: privateKey,
                passphrase: password
            )
            DispatchQueue.main.async {
                switch keystore {
                case .success(let result):
                    completion(.success(result.jsonString ?? ""))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }

    func importKeystore(value: String, password: String, newPassword: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.importKeystore(value: value, password: password, newPassword: newPassword)
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
        let account = try! keyStore.createAccount(password: password)
        let _ = setPassword(password, for: account)
        return account
    }

    func importKeystore(value: String, password: String, newPassword: String) -> Result<Account, KeystoreError> {
        guard let data = value.data(using: .utf8) else {
            return (.failure(.failedToParseJSON))
        }
        do {
            let account = try keyStore.import(json: data, password: password, newPassword: newPassword)
            let _ = setPassword(newPassword, for: account)
            return .success(account)
        } catch {
            if case KeyStore.Error.accountAlreadyExists = error {
                return .failure(.duplicateAccount)
            } else {
                return .failure(.failedToImport(error))
            }
        }
    }

    var accounts: [Account] {
        return keyStore.accounts
    }

    func export(account: Account, password: String, newPassword: String) -> Result<String, KeystoreError> {
        let result = exportData(account: account, password: password, newPassword: newPassword)
        switch result {
        case .success(let data):
            let string = String(data: data, encoding: .utf8) ?? ""
            return .success(string)
        case .failure(let error):
            return .failure(error)
        }
    }

    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeystoreError> {
        guard let account = getAccount(for: account.address) else {
            return .failure(.accountNotFound)
        }

        do {
            let data = try keyStore.export(account: account, password: password, newPassword: newPassword)
            return (.success(data))
        } catch {
            return (.failure(.failedToDecryptKey))
        }
    }

    func delete(account: Account) -> Result<Void, KeystoreError> {
        guard let account = getAccount(for: account.address) else {
            return .failure(.accountNotFound)
        }

        guard let password = getPassword(for: account) else {
            return .failure(.failedToDeleteAccount)
        }

        do {
            try keyStore.delete(account: account, password: password)
            return .success(())
        } catch {
            return .failure(.failedToDeleteAccount)
        }
    }

    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeystoreError> {
        guard let account = getAccount(for: account.address) else {
            return .failure(.accountNotFound)
        }

        do {
            try keyStore.update(account: account, password: password, newPassword: newPassword)
            return .success(())
        } catch {
            return .failure(.failedToUpdatePassword)
        }
    }

    func signTransaction(_ transaction: SignTransaction) -> Result<Data, KeystoreError> {
        guard let account = keyStore.account(for: transaction.account.address) else {
            return .failure(.failedToSignTransaction)
        }
        guard let password = getPassword(for: account) else {
            return .failure(.failedToSignTransaction)
        }

        let signer: Signer
        if transaction.chainID == 0 {
            signer = HomesteadSigner()
        } else {
            signer = EIP155Signer(chainId: BigInt(transaction.chainID))
        }

        do {
            let hash = signer.hash(transaction: transaction)
            let signature = try keyStore.signHash(hash, account: account, password: password)
            let (r, s, v) = signer.values(transaction: transaction, signature: signature)
            let data = RLP.encode([
                transaction.nonce,
                transaction.gasPrice,
                transaction.gasLimit,
                transaction.address.data,
                transaction.value,
                transaction.data,
                v, r, s,
            ])!
            return .success(data)
        } catch {
            return .failure(.failedToSignTransaction)
        }
    }

    func getPassword(for account: Account) -> String? {
        return keychain.get(account.address.address.lowercased())
    }

    @discardableResult
    func setPassword(_ password: String, for account: Account) -> Bool {
        return keychain.set(password, forKey: account.address.address.lowercased(), withAccess: defaultKeychainAccess)
    }

    func getAccount(for address: Address) -> Account? {
        return keyStore.account(for: address)
    }

    func convertPrivateKeyToKeystoreFile(privateKey: String, passphrase: String) -> Result<[String: Any], KeystoreError> {
        guard let data = Data(hexString: privateKey) else {
            return .failure(KeystoreError.failedToImportPrivateKey)
        }
        do {
            let key = try Key(password: passphrase, key: data)
            let data = try JSONEncoder().encode(key)
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            return .success(dict)
        } catch {
            return .failure(KeystoreError.failedToImportPrivateKey)
        }
    }
}
