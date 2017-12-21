// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class MigrationInitializer: Initializer {

    let account: Account
    let chainID: Int

    init(
        account: Account, chainID: Int
    ) {
        self.account = account
        self.chainID = chainID
    }

    func perform() {
        var config = RealmConfiguration.configuration(for: account, chainID: chainID)
        config.schemaVersion = 30
        config.migrationBlock = { _, _ in }
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
    }
}
