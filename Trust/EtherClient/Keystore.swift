// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import TrustKeystore

protocol Keystore {
    var hasWallets: Bool { get }
    var wallets: [Wallet] { get }
    var keystoreDirectory: URL { get }
    var recentlyUsedWallet: Wallet? { get set }
    static var current: Wallet? { get }
    @available(iOS 10.0, *)
    func createAccount(with password: String, completion: @escaping (Result<Account, KeystoreError>) -> Void)
    func importWallet(type: ImportType, completion: @escaping (Result<Wallet, KeystoreError>) -> Void)
    func keystore(for privateKey: String, password: String, completion: @escaping (Result<String, KeystoreError>) -> Void)
    func importKeystore(value: String, password: String, newPassword: String, completion: @escaping (Result<Account, KeystoreError>) -> Void)
    func createAccout(password: String) -> Account
    func importKeystore(value: String, password: String, newPassword: String) -> Result<Account, KeystoreError>
    func export(account: Account, password: String, newPassword: String) -> Result<String, KeystoreError>
    func export(account: Account, password: String, newPassword: String, completion: @escaping (Result<String, KeystoreError>) -> Void)
    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeystoreError>
    func delete(wallet: Wallet) -> Result<Void, KeystoreError>
    func delete(wallet: Wallet, completion: @escaping (Result<Void, KeystoreError>) -> Void)
    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeystoreError>
    func signMessage(message: String, account: Account) -> Result<Data, KeystoreError>
    func signTransaction(_ signTransaction: SignTransaction) -> Result<Data, KeystoreError>
    func getPassword(for account: Account) -> String?
    func convertPrivateKeyToKeystoreFile(privateKey: String, passphrase: String) -> Result<[String: Any], KeystoreError>
}
