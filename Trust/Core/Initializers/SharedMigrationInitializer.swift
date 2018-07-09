// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift

final class SharedMigrationInitializer: Initializer {

    lazy var config: Realm.Configuration = {
        return RealmConfiguration.sharedConfiguration()
    }()

    init() { }

    func perform() {
        config.schemaVersion = Config.dbMigrationSchemaVersion
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
