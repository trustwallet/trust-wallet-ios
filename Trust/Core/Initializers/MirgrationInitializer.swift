// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustKeystore

class MigrationInitializer: Initializer {

    let account: Wallet
    let chainID: Int

    init(
        account: Wallet, chainID: Int
    ) {
        self.account = account
        self.chainID = chainID
    }

    func perform() {
        var config = RealmConfiguration.configuration(for: account, chainID: chainID)
        config.schemaVersion = 32
        config.migrationBlock = { _, _ in }
        Realm.Configuration.defaultConfiguration = config
    }
}
