// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class SharedMigrationInitializer: Initializer {

    private let schemaVersion = Config.dbMigrationSchemaVersion

    lazy var config: Realm.Configuration = {
        return RealmConfiguration.sharedConfiguration(with: schemaVersion)
    }()

    init() { }

    func perform() {
        config.schemaVersion = schemaVersion
        config.migrationBlock = { migration, oldSchemaVersion in
            switch oldSchemaVersion {
            case 0...52:
                migration.deleteData(forType: CoinTicker.className)
            default:
                break
            }
        }
    }
}
