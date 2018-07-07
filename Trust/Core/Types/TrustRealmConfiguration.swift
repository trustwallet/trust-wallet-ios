// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift
import TrustCore

struct RealmConfiguration {

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
}
