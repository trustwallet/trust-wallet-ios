// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class MigrationInitializer {

    init() {

    }

    func perform() {
        let config = Realm.Configuration(
            schemaVersion: 16,
            migrationBlock: { _, _ in }
        )
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
    }
}
