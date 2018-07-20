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

    static func configuration(for account: WalletInfo) -> Realm.Configuration {
        var config = Realm.Configuration()
        let directory = config.fileURL!.deletingLastPathComponent()
        let newURL = directory.appendingPathComponent("\(account.description).realm")
        config.fileURL = newURL
        return config
    }
}
