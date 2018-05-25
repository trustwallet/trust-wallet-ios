// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class SharedMigrationInitializer: Initializer {

    private let schemaVersion: UInt64 = 6

    lazy var config: Realm.Configuration = {
        return RealmConfiguration.sharedConfiguration(with: schemaVersion)
    }()

    init() { }

    func perform() {
        config.schemaVersion = schemaVersion
        config.migrationBlock = { migration, oldSchemaVersion in
            switch oldSchemaVersion {
            default:
                break
            }
        }
    }
}
