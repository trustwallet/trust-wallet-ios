// Copyright DApps Platform Inc. All rights reserved.

import BigInt
import Foundation
import Result
import KeychainSwift
import CryptoSwift
import TrustCore
import TrustKeystore

enum EtherKeystoreError: LocalizedError {
    case protectionDisabled
}

class EtherKeystore: Keystore {
    struct Keys {
        static let recentlyUsedAddress: String = "recentlyUsedAddress"
        static let recentlyUsedWallet: String = "recentlyUsedWallet"
    }

    private let keychain: KeychainSwift
    private let datadir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    let keyStore: KeyStore
    private let defaultKeychainAccess: KeychainSwiftAccessOptions = .accessibleWhenUnlockedThisDeviceOnly
    let keysDirectory: URL
    let userDefaults: UserDefaults
    let storage: WalletStorage

    public init(
        keychain: KeychainSwift = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix),
        keysSubfolder: String = "/keystore",
        userDefaults: UserDefaults = UserDefaults.standard,
        storage: WalletStorage
    ) {
        self.keysDirectory = URL(fileURLWithPath: datadir + keysSubfolder)
        self.keychain = keychain
        self.keychain.synchronizable = false
        self.keyStore = try! KeyStore(keyDirectory: keysDirectory)
        self.userDefaults = userDefaults
        self.storage = storage
    }

    var hasWallets: Bool {
        return !wallets.isEmpty
    }

    var mainWallet: WalletInfo? {
        return wallets.filter { $0.mainWallet }.first
    }

    var wallets: [WalletInfo] {
        return [
            keyStore.wallets.filter { !$0.accounts.isEmpty }.compactMap {
                switch $0.type {
                case .encryptedKey:
                    let type = WalletType.privateKey($0)
                    return WalletInfo(type: type, info: storage.get(for: type))
                case .hierarchicalDeterministicWallet:
                    let type = WalletType.hd($0)
                    return WalletInfo(type: type, info: storage.get(for: type))
                }
            }.filter { !$0.accounts.isEmpty },
            storage.addresses.compactMap {
                guard let address = $0.address else { return .none }
                let type = WalletType.address($0.coin, address)
                return WalletInfo(type: type, info: storage.get(for: type))
            },
        ].flatMap { $0 }.sorted(by: { $0.info.createdAt < $1.info.createdAt })
    }

    var recentlyUsedWallet: WalletInfo? {
        set {
            keychain.set(newValue?.description ?? "", forKey: Keys.recentlyUsedWallet, withAccess: defaultKeychainAccess)
        }
        get {
            let walletKey = keychain.get(Keys.recentlyUsedWallet)
            let foundWallet = wallets.filter { $0.description == walletKey }.first
            guard let wallet = foundWallet else {
                // Old way to match recently selected address
                let address = keychain.get(Keys.recentlyUsedAddress)
                return wallets.filter {
                    $0.address.description == address || $0.description.lowercased() == address?.lowercased()
                }.first
            }
            return wallet
        }
    }

    // Async
    @available(iOS 10.0, *)
    func createAccount(with password: String, completion: @escaping (Result<Wallet, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let account = self.createAccout(password: password)
            DispatchQueue.main.async {
                completion(.success(account))
            }
        }
    }

    func importWallet(type: ImportType, coin: Coin, completion: @escaping (Result<WalletInfo, KeystoreError>) -> Void) {
        let newPassword = PasswordGenerator.generateRandom()
        switch type {
        case .keystore(let string, let password):
            importKeystore(
                value: string,
                password: password,
                newPassword: newPassword,
                coin: coin
            ) { result in
                switch result {
                case .success(let account):
                    let type = WalletType.privateKey(account)
                    completion(.success(WalletInfo(type: type, info: self.storage.get(for: type))))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .privateKey(let privateKey):
            let privateKeyData = PrivateKey(data: Data(hexString: privateKey)!)!
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    let wallet = try self.keyStore.import(privateKey: privateKeyData, password: newPassword, coin: coin)
                    self.setPassword(newPassword, for: wallet)
                    DispatchQueue.main.async {
                        completion(.success(WalletInfo(type: .privateKey(wallet))))
                    }
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(KeystoreError.failedToImportPrivateKey))
                    }
                }
            }
        case .mnemonic(let words, let passphrase, let derivationPath):
            let string = words.map { String($0) }.joined(separator: " ")
            if !Crypto.isValid(mnemonic: string) {
                return completion(.failure(KeystoreError.invalidMnemonicPhrase))
            }
            do {
                let account = try keyStore.import(mnemonic: string, passphrase: passphrase, encryptPassword: newPassword, derivationPath: derivationPath)
                setPassword(newPassword, for: account)
                completion(.success(WalletInfo(type: .hd(account))))
            } catch {
                return completion(.failure(KeystoreError.duplicateAccount))
            }
        case .address(let address):
            let watchAddress = WalletAddress(coin: coin, address: address)
            guard !storage.addresses.contains(watchAddress) else {
                return completion(.failure(.duplicateAccount))
            }
            storage.store(address: [watchAddress])
            let type = WalletType.address(coin, address)
            completion(.success(WalletInfo(type: type, info: storage.get(for: type))))
        }
    }

    func importKeystore(value: String, password: String, newPassword: String, coin: Coin, completion: @escaping (Result<Wallet, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.importKeystore(value: value, password: password, newPassword: newPassword, coin: coin)
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

    func createAccout(password: String) -> Wallet {
        let derivationPaths = Config.current.servers.map { $0.derivationPath(at: 0) }
        let wallet = try! keyStore.createWallet(
            password: password,
            derivationPaths: derivationPaths
        )
        let _ = setPassword(password, for: wallet)
        return wallet
    }

    func importPrivateKey(privateKey: PrivateKey, password: String, coin: Coin) -> Result<WalletInfo, KeystoreError> {
        do {
            let wallet = try keyStore.import(privateKey: privateKey, password: password, coin: coin)
            let w = WalletInfo(type: .privateKey(wallet))
            let _ = setPassword(password, for: wallet)
            return .success(w)
        } catch {
            return .failure(.failedToImport(error))
        }
    }

    func importKeystore(value: String, password: String, newPassword: String, coin: Coin) -> Result<Wallet, KeystoreError> {
        guard let data = value.data(using: .utf8) else {
            return (.failure(.failedToParseJSON))
        }
        do {
            //TODO: Blockchain. Pass blockchain ID
            let wallet = try keyStore.import(json: data, password: password, newPassword: newPassword, coin: coin)
            let _ = setPassword(newPassword, for: wallet)
            return .success(wallet)
        } catch {
            if case KeyStore.Error.accountAlreadyExists = error {
                return .failure(.duplicateAccount)
            } else {
                return .failure(.failedToImport(error))
            }
        }
    }

    func export(account: Account, password: String, newPassword: String) -> Result<String, KeystoreError> {
        let result = self.exportData(account: account, password: password, newPassword: newPassword)
        switch result {
        case .success(let data):
            let string = String(data: data, encoding: .utf8) ?? ""
             return .success(string)
        case .failure(let error):
             return .failure(error)
        }
    }

    func export(account: Account, password: String, newPassword: String, completion: @escaping (Result<String, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.export(account: account, password: password, newPassword: newPassword)
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }

    func exportData(account: Account, password: String, newPassword: String) -> Result<Data, KeystoreError> {
        do {
            let data = try keyStore.export(wallet: account.wallet!, password: password, newPassword: newPassword)
            return (.success(data))
        } catch {
            return (.failure(.failedToDecryptKey))
        }
    }

    func exportPrivateKey(account: Account, completion: @escaping (Result<Data, KeystoreError>) -> Void) {
        guard let password = getPassword(for: account.wallet!) else {
            return completion(.failure(KeystoreError.accountNotFound))
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let privateKey = try account.privateKey(password: password).data
                DispatchQueue.main.async {
                    completion(.success(privateKey))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(KeystoreError.accountNotFound))
                }
            }
        }
    }

    func exportMnemonic(wallet: Wallet, completion: @escaping (Result<[String], KeystoreError>) -> Void) {
        guard let password = getPassword(for: wallet) else {
            return completion(.failure(KeystoreError.accountNotFound))
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let mnemonic = try  self.keyStore.exportMnemonic(wallet: wallet, password: password)
                let words = mnemonic.components(separatedBy: " ")
                DispatchQueue.main.async {
                    completion(.success(words))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(KeystoreError.accountNotFound))
                }
            }
        }
    }

    func delete(wallet: Wallet) -> Result<Void, KeystoreError> {
        guard let password = getPassword(for: wallet) else {
            return .failure(.failedToDeleteAccount)
        }
        do {
            try keyStore.delete(wallet: wallet, password: password)
            return .success(())
        } catch {
            return .failure(.failedToDeleteAccount)
        }
    }

    func delete(wallet: WalletInfo, completion: @escaping (Result<Void, KeystoreError>) -> Void) {
        switch wallet.type {
        case .privateKey(let w), .hd(let w):
            DispatchQueue.global(qos: .userInitiated).async {
                let result = self.delete(wallet: w)
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        case .address(let coin, let address):
            let first = storage.realm.objects(WalletAddress.self).filter { $0.address == address && $0.coin == coin }.first
            guard let walletAddress = first else {
                return completion(.failure(KeystoreError.accountNotFound))
            }
            storage.delete(address: walletAddress)
            return completion(.success(()))
        }
    }

    func addAccount(to wallet: Wallet, derivationPaths: [DerivationPath]) -> Result<Void, KeystoreError> {
        guard let password = getPassword(for: wallet) else {
            return .failure(.failedToDeleteAccount)
        }
        do {
            let _ = try keyStore.addAccounts(wallet: wallet, derivationPaths: derivationPaths, password: password)
            return .success(())
        } catch {
            return .failure(KeystoreError.failedToAddAccounts)
        }
    }

    func update(wallet: Wallet) -> Result<Void, KeystoreError> {
        guard let password = getPassword(for: wallet) else {
            return .failure(.failedToDeleteAccount)
        }
        try? keyStore.update(wallet: wallet, password: password, newPassword: password)
        return .success(())
    }

    func signPersonalMessage(_ message: Data, for account: Account) -> Result<Data, KeystoreError> {
        let prefix = "\u{19}Ethereum Signed Message:\n\(message.count)".data(using: .utf8)!
        return signMessage(prefix + message, for: account)
    }

    func signMessage(_ message: Data, for account: Account) -> Result<Data, KeystoreError> {
        return signHash(message.sha3(.keccak256), for: account)
    }

    func signTypedMessage(_ datas: [EthTypedData], for account: Account) -> Result<Data, KeystoreError> {
        let schemas = datas.map { $0.schemaData }.reduce(Data(), { $0 + $1 }).sha3(.keccak256)
        let values = datas.map { $0.typedData }.reduce(Data(), { $0 + $1 }).sha3(.keccak256)
        let combined = (schemas + values).sha3(.keccak256)
        return signHash(combined, for: account)
    }

    func signHash(_ hash: Data, for account: Account) -> Result<Data, KeystoreError> {
        guard
            let password = getPassword(for: account.wallet!) else {
                return .failure(KeystoreError.failedToSignMessage)
        }
        do {
            var data = try account.sign(hash: hash, password: password)
            // TODO: Make it configurable, instead of overriding last byte.
            data[64] += 27
            return .success(data)
        } catch {
            return .failure(KeystoreError.failedToSignMessage)
        }
    }

    func signTransaction(_ transaction: SignTransaction) -> Result<Data, KeystoreError> {
        let account = transaction.account
        guard let wallet  = account.wallet, let password = getPassword(for: wallet) else {
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
            let signature = try account.sign(hash: hash, password: password)
            let (r, s, v) = signer.values(transaction: transaction, signature: signature)
            let data = RLP.encode([
                transaction.nonce,
                transaction.gasPrice,
                transaction.gasLimit,
                transaction.to?.data ?? Data(),
                transaction.value,
                transaction.data,
                v, r, s,
            ])!
            return .success(data)
        } catch {
            return .failure(.failedToSignTransaction)
        }
    }

    func getPassword(for account: Wallet) -> String? {
        let key = keychainKey(for: account)
        return keychain.get(key)
    }

    @discardableResult
    func setPassword(_ password: String, for account: Wallet) -> Bool {
        let key = keychainKey(for: account)
        return keychain.set(password, forKey: key, withAccess: defaultKeychainAccess)
    }

    internal func keychainKey(for account: Wallet) -> String {
        return account.identifier
    }

    func store(object: WalletObject, fields: [WalletInfoField]) {
        try? storage.realm.write {
            for field in fields {
                switch field {
                case .name(let name):
                    object.name = name
                case .backup(let completedBackup):
                    object.completedBackup = completedBackup
                case .mainWallet(let mainWallet):
                    object.mainWallet = mainWallet
                case .balance(let balance):
                    object.balance = balance
                }
            }
            storage.realm.add(object, update: true)
        }
    }
}
