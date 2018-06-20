// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import TrustKeystore
import Result

struct FakeKeystore: Keystore {

    static var current: Trust.Wallet?
    var hasWallets: Bool {
        return wallets.count > 0
    }
    var keysDirectory: URL {
        return URL(fileURLWithPath: "file://")
    }
    var walletsDirectory: URL {
        return URL(fileURLWithPath: "file://")
    }
    var wallets: [Trust.Wallet]
    var recentlyUsedWallet: Trust.Wallet?

    init(
        wallets: [Trust.Wallet] = [],
        recentlyUsedWallet: Trust.Wallet? = .none
    ) {
        self.wallets = wallets
        self.recentlyUsedWallet = recentlyUsedWallet
    }

    func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        completion(.success(.make()))
    }

    func importWallet(type: ImportType, completion: @escaping (Result<Trust.Wallet, KeystoreError>) -> Void) {
        //TODO: Implement
    }

    func keystore(for privateKey: String, password: String, completion: @escaping (Result<String, KeystoreError>) -> Void) {
        //TODO: Implement
    }

    func importKeystore(value: String, password: String, newPassword: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        //TODO: Implement
    }

    func createAccout(password: String) -> Account {
        //TODO: Implement
        return .make(address: .make())
    }

    func importKeystore(value: String, password: String, newPassword: String) -> Result<Account, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func export(account: Account, password: String, newPassword: String) -> Result<String, KeystoreError> {
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func export(account: Account, password: String, newPassword: String, completion: @escaping (Result<String, KeystoreError>) -> Void) {
        //TODO: Implement
        return completion(.failure(KeystoreError.failedToSignTransaction))
    }

    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func exportMnemonic(account: Account, completion: @escaping (Result<String, KeystoreError>) -> Void) {
        //TODO: Implement
        return completion(.failure(KeystoreError.failedToSignTransaction))
    }

    func delete(wallet: Trust.Wallet) -> Result<Void, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func delete(wallet: Trust.Wallet, completion: @escaping (Result<Void, KeystoreError>) -> Void) {
        completion(.failure(KeystoreError.failedToSignTransaction))
    }

    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func signPersonalMessage(_ data: Data, for account: Account) -> Result<Data, KeystoreError> {
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func signMessage(_ data: Data, for account: Account) -> Result<Data, KeystoreError> {
        return .failure(KeystoreError.failedToSignMessage)
    }

    func signTypedMessage(_ datas: [EthTypedData], for account: Account) -> Result<Data, KeystoreError> {
        return .failure(KeystoreError.failedToSignTypedMessage)
    }

    func signHash(_ hash: Data, for account: Account) -> Result<Data, KeystoreError> {
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func signTransaction(_ signTransaction: SignTransaction) -> Result<Data, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func getPassword(for account: Account) -> String? {
        //TODO: Implement
        return .none
    }

    func convertPrivateKeyToKeystoreFile(privateKey: String, passphrase: String) -> Result<[String : Any], KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToSignTransaction)
    }

    func exportPrivateKey(account: Account) -> Result<Data, KeystoreError> {
        //TODO: Implement
        return .failure(KeystoreError.failedToExportPrivateKey)
    }
}

extension FakeKeystore {
    static func make(
        wallets: [Trust.Wallet] = [],
        recentlyUsedWallet: Trust.Wallet? = .none
    ) -> FakeKeystore {
        return FakeKeystore(
            wallets: wallets,
            recentlyUsedWallet: recentlyUsedWallet
        )
    }
}
