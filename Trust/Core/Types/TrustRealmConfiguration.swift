// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustKeystore

struct RealmConfiguration {

    static func configuration(for account: Account, chainID: Int) -> Realm.Configuration {
        var config = Realm.Configuration()
        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(account.address.description)-\(chainID).realm")
        return config
    }
}
