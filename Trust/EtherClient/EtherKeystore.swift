// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Geth
import Result
import KeychainSwift

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

    func createAccout(password: String) -> Account {
        let gethAccount = try! gethKeyStorage.newAccount(password)
        let account: Account = .from(account: gethAccount)
        let _ = setPassword(password, for: account)
        return account
    }

    func importKeystore(value: String, password: String) -> Result<Account, KeyStoreError> {
        let data = value.data(using: .utf8)
        do {
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

    func export(account: Account, password: String) -> Result<String, KeyStoreError> {
        let result = exportData(account: account, password: password)
        switch result {
        case .success(let data):
            let string = String(data: data, encoding: .utf8) ?? ""
            return (.success(string))
        case .failure(let error):
            return (.failure(error))
        }
    }

    func exportData(account: Account, password: String) -> Result<Data, KeyStoreError> {
        let gethAccount = getGethAccount(for: account.address)
        do {
            let data = try gethKeyStorage.exportKey(gethAccount, passphrase: password, newPassphrase: password)
            return (.success(data))
        } catch {
            return (.failure(.failedToDecryptKey))
        }
    }

    func delete(account: Account, password: String) -> Result<Void, KeyStoreError> {
        let gethAccount = getGethAccount(for: account.address)

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
        amount: GethBigInt,
        account: Account,
        address: Address,
        nonce: Int64,
        speed: TransactionSpeed,
        data: Data = Data(),
        chainID: GethBigInt = GethNewBigInt(1)
    ) -> Result<Data, KeyStoreError> {

        let gethAddress = GethNewAddressFromHex(address.address, nil)
        let transaction = GethNewTransaction(nonce, gethAddress, amount, speed.gasLimit, speed.gasPrice, data)
        let password = getPassword(for: account)

        let gethAccount = getGethAccount(for: account.address)

        do {
            try gethKeyStorage.unlock(gethAccount, passphrase: password)
            let signedTransaction = try gethKeyStorage.signTx(gethAccount, tx: transaction, chainID: chainID)
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
}

extension Account {
    static func from(account: GethAccount) -> Account {
        return Account(
            address: Address(address: account.getAddress().getHex())
        )
    }
}
