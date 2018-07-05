// Copyright SIX DAY LLC. All rights reserved.

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

open class EtherKeystore: Keystore {
    struct Keys {
        static let recentlyUsedAddress: String = "recentlyUsedAddress"
        static let recentlyUsedWallet: String = "recentlyUsedWallet"
        static let watchAddresses = "watchAddresses"
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

    var wallets: [WalletInfo] {
        return accounts.map {
            return WalletInfo(wallet: $0, info: storage.get(for: $0))
        }.sorted(by: { $0.info.createdAt < $1.info.createdAt })
    }

    private var accounts: [Wallet] {
        let addresses = watchAddresses.compactMap { Address(string: $0) }
        return [
            keyStore.accounts.map {
                switch $0.type {
                case .encryptedKey: return Wallet(type: .privateKey($0))
                case .hierarchicalDeterministicWallet: return Wallet(type: .hd($0))
                }
            },
            addresses.map { Wallet(type: .address($0)) },
        ].flatMap { $0 }
    }

    private var watchAddresses: [String] {
        set {
            let data = NSKeyedArchiver.archivedData(withRootObject: newValue)
            return userDefaults.set(data, forKey: Keys.watchAddresses)
        }
        get {
            guard let data = userDefaults.data(forKey: Keys.watchAddresses) else { return [] }
            return NSKeyedUnarchiver.unarchiveObject(with: data) as? [String] ?? []
        }
     }

    var recentlyUsedWallet: WalletInfo? {
        set {
            keychain.set(newValue?.wallet.description ?? "", forKey: Keys.recentlyUsedWallet, withAccess: defaultKeychainAccess)
        }
        get {
            let walletKey = keychain.get(Keys.recentlyUsedWallet)
            let foundWallet = wallets.filter { $0.wallet.description == walletKey }.first
            guard let wallet = foundWallet else {
                // Old way to match recently selected address
                let address = keychain.get(Keys.recentlyUsedAddress)
                return wallets.filter {
                    $0.wallet.address.description == address || $0.wallet.address.description.lowercased() == address?.lowercased()
                }.first
            }
            return wallet
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

    func importWallet(type: ImportType, completion: @escaping (Result<Wallet, KeystoreError>) -> Void) {
        let newPassword = PasswordGenerator.generateRandom()
        switch type {
        case .keystore(let string, let password):
            importKeystore(
                value: string,
                password: password,
                newPassword: newPassword
            ) { result in
                switch result {
                case .success(let account):
                    completion(.success(Wallet(type: .privateKey(account))))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .privateKey(let privateKey):
            keystore(for: privateKey, password: newPassword) { result in
                switch result {
                case .success(let value):
                    self.importKeystore(
                        value: value,
                        password: newPassword,
                        newPassword: newPassword
                    ) { result in
                        switch result {
                        case .success(let account):
                            completion(.success(Wallet(type: .privateKey(account))))
                        case .failure(let error):
                            completion(.failure(error))
                        }
                    }
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        case .mnemonic(let words, let passphrase):
            let string = words.map { String($0) }.joined(separator: " ")
            if !Mnemonic.isValid(string) {
                return completion(.failure(KeystoreError.invalidMnemonicPhrase))
            }
            do {
                let account = try keyStore.import(mnemonic: string, passphrase: passphrase, encryptPassword: newPassword)
                setPassword(newPassword, for: account)
                completion(.success(Wallet(type: .hd(account))))
            } catch {
                return completion(.failure(KeystoreError.duplicateAccount))
            }
        case .watch(let address):
            let addressString = address.description
            guard !watchAddresses.contains(addressString) else {
                return completion(.failure(.duplicateAccount))
            }
            self.watchAddresses = [watchAddresses, [addressString]].flatMap { $0 }
            completion(.success(Wallet(type: .address(address))))
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
        let account = try! keyStore.createAccount(password: password, type: .hierarchicalDeterministicWallet)
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

    func exportPrivateKey(account: Account, completion: @escaping (Result<Data, KeystoreError>) -> Void) {
        guard let password = getPassword(for: account) else {
            return completion(.failure(KeystoreError.accountNotFound))
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let privateKey = try self.keyStore.exportPrivateKey(account: account, password: password)
                DispatchQueue.main.async {
                    completion(.success(privateKey))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(KeystoreError.failedToDecryptKey))
                }
            }
        }
    }

    func exportMnemonic(account: Account, completion: @escaping (Result<[String], KeystoreError>) -> Void) {
        guard let password = getPassword(for: account) else {
            return completion(.failure(KeystoreError.accountNotFound))
        }
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let mnemonic = try self.keyStore.exportMnemonic(account: account, password: password)
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
        switch wallet.type {
        case .privateKey(let account), .hd(let account):
            guard let password = getPassword(for: account) else {
                return .failure(.failedToDeleteAccount)
            }

            do {
                try keyStore.delete(account: account, password: password)
                return .success(())
            } catch {
                return .failure(.failedToDeleteAccount)
            }
        case .address(let address):
            watchAddresses = watchAddresses.filter { $0 != address.description }
            return .success(())
        }
    }

    func delete(wallet: Wallet, completion: @escaping (Result<Void, KeystoreError>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            let result = self.delete(wallet: wallet)
            DispatchQueue.main.async {
                completion(result)
            }
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
            let password = getPassword(for: account) else {
                return .failure(KeystoreError.failedToSignMessage)
        }
        do {
            var data = try keyStore.signHash(hash, account: account, password: password)
            // TODO: Make it configurable, instead of overriding last byte.
            data[64] += 27
            return .success(data)
        } catch {
            return .failure(KeystoreError.failedToSignMessage)
        }
    }

    func signTransaction(_ transaction: SignTransaction) -> Result<Data, KeystoreError> {
        let account = transaction.account
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

    func getPassword(for account: Account) -> String? {
        return keychain.get(keychainKey(for: account))
    }

    @discardableResult
    func setPassword(_ password: String, for account: Account) -> Bool {
        return keychain.set(password, forKey: keychainKey(for: account), withAccess: defaultKeychainAccess)
    }

    internal func keychainKey(for account: Account) -> String {
        switch account.type {
        case .encryptedKey:
            return account.address.description.lowercased()
        case .hierarchicalDeterministicWallet:
            return "hd-wallet-" + account.address.description
        }
    }

    func getAccount(for address: Address) -> Account? {
        return keyStore.account(for: address)
    }

    func convertPrivateKeyToKeystoreFile(privateKey: String, passphrase: String) -> Result<[String: Any], KeystoreError> {
        guard let data = Data(hexString: privateKey) else {
            return .failure(KeystoreError.failedToImportPrivateKey)
        }
        do {
            let key = try KeystoreKey(password: passphrase, key: data)
            let data = try JSONEncoder().encode(key)
            let dict = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            return .success(dict)
        } catch {
            return .failure(KeystoreError.failedToImportPrivateKey)
        }
    }

    func store(object: WalletObject, fields: [WalletInfoField]) {
        try? storage.realm.write {
            for field in fields {
                switch field {
                case .name(let name):
                    object.name = name
                }
            }
            storage.realm.add(object, update: true)
        }
    }
}
