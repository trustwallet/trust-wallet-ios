// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustCore
import KeychainSwift

struct RealmConfiguration {

    private static let realmKey = "realmKey"

    private static let keychain = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix)

    static func sharedConfiguration() -> Realm.Configuration {
        var config = Realm.Configuration()
        let directory = config.fileURL!.deletingLastPathComponent()
        let url = directory.appendingPathComponent("shared.realm")
        return Realm.Configuration(fileURL: url)
    }

    static func configuration(for account: Wallet, chainID: Int) -> Realm.Configuration {
        var config = Realm.Configuration()
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

    private static func saveKey(key: String) {
        keychain.set(key, forKey: realmKey)
    }

    private static func getKey() -> String? {
        return keychain.get(realmKey)
    }

    private static func generateKey() -> String? {
        var keyData = Data(count: 64)
        var key = keyData
        let result = key.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, keyData.count, $0)
        }
        if result == errSecSuccess {
            return key.base64EncodedString()
        } else {
            return nil
        }
    }
}
