// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class MigrationInitializer: Initializer {

    func perform() {
        let config = Realm.Configuration(
            schemaVersion: 18,
            migrationBlock: { _, _ in }
        )
        Realm.Configuration.defaultConfiguration = config
        let _ = try! Realm()
    }
}
