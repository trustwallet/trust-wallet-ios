// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustKeystore
import TrustCore
import Result

struct FakeKeystore: Keystore {
    var mainWallet: WalletInfo? {
        return wallets.filter { $0.mainWallet }.first
    }

    var storage: WalletStorage {
        return WalletStorage(realm: .make())
    }

    func createAccount(with password: String, completion: @escaping (Result<Wallet, KeystoreError>) -> Void) {
        //
    }

    func importWallet(type: ImportType, coin: Coin, completion: @escaping (Result<WalletInfo, KeystoreError>) -> Void) {
        //
    }

    func importKeystore(value: String, password: String, newPassword: String, coin: Coin, completion: @escaping (Result<WalletInfo, KeystoreError>) -> Void) {
        //
    }

    func createAccout(password: String) -> Wallet {
        return .make()
    }

    func importKeystore(value: String, password: String, newPassword: String, coin: Coin) -> Result<WalletInfo, KeystoreError> {
        return .failure(KeystoreError.accountNotFound)
    }

    func importPrivateKey(privateKey: PrivateKey, password: String, coin: Coin) -> Result<WalletInfo, KeystoreError> {
        return .failure(KeystoreError.accountNotFound)
    }

    func exportMnemonic(wallet: Wallet, completion: @escaping (Result<[String], KeystoreError>) -> Void) {
        //
    }

    func delete(wallet: Wallet) -> Result<Void, KeystoreError> {
        return .failure(KeystoreError.accountNotFound)
    }

    func delete(wallet: WalletInfo, completion: @escaping (Result<Void, KeystoreError>) -> Void) {
        ///
    }

    func getPassword(for account: Wallet) -> String? {
        return "test"
    }

    func setPassword(_ password: String, for account: Wallet) -> Bool {
        return true
    }

    func addAccount(to wallet: Wallet, derivationPaths: [DerivationPath]) -> Result<Void, KeystoreError> {
        return .failure(KeystoreError.accountNotFound)
    }

    func update(wallet: Wallet) -> Result<Void, KeystoreError> {
        return .failure(KeystoreError.accountNotFound)
    }

    var hasWallets: Bool {
        return wallets.count > 0
    }
    var keysDirectory: URL {
        return URL(fileURLWithPath: "file://")
    }
    var walletsDirectory: URL {
        return URL(fileURLWithPath: "file://")
    }
    var wallets: [Trust.WalletInfo]
    var recentlyUsedWallet: Trust.WalletInfo?

    init(
        wallets: [Trust.WalletInfo] = [],
        recentlyUsedWallet: Trust.WalletInfo? = .none
    ) {
        self.wallets = wallets
        self.recentlyUsedWallet = recentlyUsedWallet
    }

    func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void) {
        completion(.success(.make()))
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

    func exportMnemonic(account: Account, completion: @escaping (Result<[String], KeystoreError>) -> Void) {
        //TODO: Implement
        return completion(.success([]))
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

    func exportPrivateKey(account: Account, completion: @escaping (Result<Data, KeystoreError>) -> Void) {
        //TODO: Implement
        return completion(.failure(KeystoreError.failedToExportPrivateKey))
    }

    func store(object: WalletObject, fields: [WalletInfoField]) {
        //TODO
    }
}

extension FakeKeystore {
    static func make(
        wallets: [Trust.WalletInfo] = [],
        recentlyUsedWallet: Trust.WalletInfo? = .none
    ) -> FakeKeystore {
        return FakeKeystore(
            wallets: wallets,
            recentlyUsedWallet: recentlyUsedWallet
        )
    }
}
