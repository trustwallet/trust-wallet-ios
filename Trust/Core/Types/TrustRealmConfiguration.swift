// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustCore
import SAMKeychain

struct RealmConfiguration {

    private static let fileManager = FileManager.default

    private static let sharedRealmKey = "sharedRealmKey"
    private static let walletsRealmKey = "walletsRealmKey"

    private struct Keys {
        static let shared = "trust.lock.shared"
        static let wallets = "trust.lock.wallets"
        static let account = "trust.realm"
    }

    static func sharedConfiguration() -> Realm.Configuration {

        let realmDefaultFolder = Realm.Configuration.defaultConfiguration.fileURL!.deletingLastPathComponent()
        let url = realmDefaultFolder.appendingPathComponent("shared.realm")

        guard let key = getKey(for: Keys.shared) else {
            let newKey = PasswordGenerator.generateRandomData(bytesCount: 64)
            encryptDatabase(with: url, and: newKey, and: Config.dbMigrationSchemaVersion)
            saveKey(key: newKey, for: Keys.account)
            return Realm.Configuration(fileURL: url, encryptionKey: newKey)
        }

        var config = Realm.Configuration(encryptionKey: key)
        config.fileURL = url
        return config
    }

    static func configuration(for account: Wallet, chainID: Int) -> Realm.Configuration {

        let realmDefaultFolder = Realm.Configuration.defaultConfiguration.fileURL!.deletingLastPathComponent()

        let oldURL = realmDefaultFolder.appendingPathComponent("\(account.address.description.lowercased())-\(chainID).realm")
        let newURL = realmDefaultFolder.appendingPathComponent("\(account.description)-\(chainID).realm")

        // Moving old users to the new realm db naming. Before if you had watch/private key for the same address it would share data between them, now it's split into separaate types.
        if fileManager.fileExists(atPath: oldURL.path) {
            do {
               try fileManager.moveItem(atPath: oldURL.path, toPath: newURL.path)
            } catch {
                return Realm.Configuration(fileURL: oldURL)
            }
        }

        guard let key = getKey(for: Keys.wallets) else {
            let newKey = PasswordGenerator.generateRandomData(bytesCount: 64)
            encryptWalletsDatabase(with: newKey)
            saveKey(key: newKey, for: Keys.wallets)
            return Realm.Configuration(fileURL: newURL, encryptionKey: newKey)
        }

        return Realm.Configuration(fileURL: newURL, encryptionKey: key)
    }

    private static func saveKey(key: Data, for type: String) {
        SAMKeychain.setPasswordData(key, forService: type, account: Keys.account)
    }

    private static func getKey(for type: String) -> Data? {
        return SAMKeychain.passwordData(forService: type, account: Keys.account)
    }

    static func cleanKeys() {
        SAMKeychain.deletePassword(forService: Keys.shared, account: Keys.account)
        SAMKeychain.deletePassword(forService: Keys.wallets, account: Keys.account)
    }

    private static func encryptWalletsDatabase(with encryptionKey: Data) {
        guard let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        let schemaVersion = Config.dbMigrationSchemaVersion
        do {
            let directoryContents = try fileManager.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            let realmDatabases = directoryContents.filter { $0.pathExtension == "realm" && $0.lastPathComponent != "shared.realm" && $0.lastPathComponent != "default.realm" }
            _ = realmDatabases.map { encryptDatabase(with: $0, and: encryptionKey, and: schemaVersion) }
        } catch {
            print(error.localizedDescription)
        }
    }

    private static func encryptDatabase(with path: URL, and encryptionKey: Data, and schemaVersion: UInt64) {
        let documentsPath = path.deletingLastPathComponent()
        let databaseUrls = [path,
            path.appendingPathExtension("lock"),
            path.appendingPathExtension("note"),
            path.appendingPathExtension("management"),
        ]
        let tempPath = documentsPath.appendingPathComponent("temp.realm")
        do {
            try autoreleasepool {
                try Realm(configuration: Realm.Configuration(fileURL: path, schemaVersion: schemaVersion)).writeCopy(toFile: tempPath, encryptionKey: encryptionKey)
                try _ = databaseUrls.map { try fileManager.removeItem(at: $0) }
                try fileManager.moveItem(at: tempPath, to: path)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
