// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class SharedMigrationInitializer: Initializer {

    lazy var config: Realm.Configuration = {
        return RealmConfiguration.sharedConfiguration()
    }()

    init() { }

    func perform() {
        config.schemaVersion = 1
        config.migrationBlock = { migration, oldSchemaVersion in
            switch oldSchemaVersion {
            default:
                break
            }
        }
    }
}

