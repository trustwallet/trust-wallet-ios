// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Result
import TrustKeystore
import TrustCore

protocol Keystore {
    var hasWallets: Bool { get }
    var wallets: [WalletInfo] { get }
    var keysDirectory: URL { get }
    var recentlyUsedWallet: WalletInfo? { get set }
    @available(iOS 10.0, *)
    func createAccount(with password: String, completion: @escaping (Result<Wallet, KeystoreError>) -> Void)
    func importWallet(type: ImportType, completion: @escaping (Result<WalletStruct, KeystoreError>) -> Void)
    func importKeystore(value: String, password: String, newPassword: String, completion: @escaping (Result<WalletStruct, KeystoreError>) -> Void)
    func createAccout(password: String) -> Wallet
    func importKeystore(value: String, password: String, newPassword: String) -> Result<WalletStruct, KeystoreError>
    func importPrivateKey(privateKey: PrivateKey, password: String) -> Result<WalletStruct, KeystoreError>
    func export(account: Account, password: String, newPassword: String) -> Result<String, KeystoreError>
    func export(account: Account, password: String, newPassword: String, completion: @escaping (Result<String, KeystoreError>) -> Void)
    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeystoreError>
    func exportPrivateKey(account: Account, completion: @escaping (Result<Data, KeystoreError>) -> Void)
    func exportMnemonic(wallet: Wallet, completion: @escaping (Result<[String], KeystoreError>) -> Void)
    func delete(wallet: WalletStruct) -> Result<Void, KeystoreError>
    func delete(wallet: WalletStruct, completion: @escaping (Result<Void, KeystoreError>) -> Void)
    func signPersonalMessage(_ data: Data, for account: Account) -> Result<Data, KeystoreError>
    func signMessage(_ message: Data, for account: Account) -> Result<Data, KeystoreError>
    func signTypedMessage(_ datas: [EthTypedData], for account: Account) -> Result<Data, KeystoreError>
    func signHash(_ hash: Data, for account: Account) -> Result<Data, KeystoreError>
    func signTransaction(_ signTransaction: SignTransaction) -> Result<Data, KeystoreError>
    func getPassword(for account: Wallet) -> String?
    func store(object: WalletObject, fields: [WalletInfoField])
}
