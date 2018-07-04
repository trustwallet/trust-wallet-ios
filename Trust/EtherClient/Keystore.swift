// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Result
import TrustKeystore

protocol Keystore {
    var hasWallets: Bool { get }
    var wallets: [WalletInfo] { get }
    var keysDirectory: URL { get }
    var recentlyUsedWallet: WalletInfo? { get set }
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
    func exportPrivateKey(account: Account, completion: @escaping (Result<Data, KeystoreError>) -> Void)
    func exportMnemonic(account: Account, completion: @escaping (Result<[String], KeystoreError>) -> Void)
    func delete(wallet: Wallet) -> Result<Void, KeystoreError>
    func delete(wallet: Wallet, completion: @escaping (Result<Void, KeystoreError>) -> Void)
    func updateAccount(account: Account, password: String, newPassword: String) -> Result<Void, KeystoreError>
    func signPersonalMessage(_ data: Data, for account: Account) -> Result<Data, KeystoreError>
    func signMessage(_ message: Data, for account: Account) -> Result<Data, KeystoreError>
    func signTypedMessage(_ datas: [EthTypedData], for account: Account) -> Result<Data, KeystoreError>
    func signHash(_ hash: Data, for account: Account) -> Result<Data, KeystoreError>
    func signTransaction(_ signTransaction: SignTransaction) -> Result<Data, KeystoreError>
    func getPassword(for account: Account) -> String?
    func convertPrivateKeyToKeystoreFile(privateKey: String, passphrase: String) -> Result<[String: Any], KeystoreError>

    func store(object: WalletObject, fields: [WalletInfoField])
}
