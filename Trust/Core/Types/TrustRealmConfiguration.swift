// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustCore
import KeychainSwift

struct RealmConfiguration {

    private static let realmKey = "realmKey"

    private static let keychain = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix)

    static func sharedConfiguration() -> Realm.Configuration {
        var config = realmSecureConfiguration()
        let directory = config.fileURL!.deletingLastPathComponent()
        let url = directory.appendingPathComponent("shared.realm")
        config.fileURL = url
        return config
    }

    static func configuration(for account: Wallet, chainID: Int) -> Realm.Configuration {
        var config = realmSecureConfiguration()
        let directory = config.fileURL!.deletingLastPathComponent()
        let oldURL = directory.appendingPathComponent("\(account.address.description.lowercased())-\(chainID).realm")
        let newURL = directory.appendingPathComponent("\(account.description)-\(chainID).realm")
        let fileManager = FileManager.default
        // Moving old users to the new realm db naming. Before if you had watch/private key for the same address it would share data between them, now it's split into separaate types.
        if fileManager.fileExists(atPath: oldURL.path) {
            do {
               try fileManager.moveItem(atPath: oldURL.path, toPath: newURL.path)
            } catch {
                config.fileURL = oldURL
                return config
            }
        }
        config.fileURL = newURL
        return config
    }

    private static func realmSecureConfiguration() -> Realm.Configuration {
        guard let key = getKey() else {
            let newKey = generateKey()
            saveKey(key: newKey)
            encryptExistingDatabases(with: newKey)
            return  Realm.Configuration(encryptionKey: newKey)
        }
        return Realm.Configuration(encryptionKey: key)
    }

    private static func saveKey(key: Data) {
        keychain.set(key, forKey: realmKey)
    }

    private static func getKey() -> Data? {
        return keychain.getData(realmKey)
    }

    private static func generateKey() -> Data {
        var keyData = Data(count: 64)
        var key = keyData
        _ = key.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, keyData.count, $0)
        }
        return key
    }

    private static func encryptExistingDatabases(with encryptionKey: Data) {
        guard let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(at: documentsUrl, includingPropertiesForKeys: nil, options: [])
            let realmDatabases = directoryContents.filter { $0.pathExtension == "realm" }
            _ = realmDatabases.map { encryptDatabase(with: $0, and: encryptionKey) }
        } catch {
            print(error.localizedDescription)
        }
    }

    private static func encryptDatabase(with path: URL, and encryptionKey: Data) {
        _ = Realm.Configuration(fileURL: path)
        let tempPath = path.appendingPathExtension("temp")
        do {
            try Realm().writeCopy(toFile: tempPath, encryptionKey: encryptionKey)
            try FileManager.default.removeItem(at: path)
            try FileManager.default.moveItem(at: tempPath, to: path)
        } catch {
            print(error.localizedDescription)
        }
    }
}
