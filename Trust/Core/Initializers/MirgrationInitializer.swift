// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift
import TrustCore

final class MigrationInitializer: Initializer {

    let account: WalletInfo
    lazy var config: Realm.Configuration = {
        return RealmConfiguration.configuration(for: account)
    }()

    init(
        account: WalletInfo
    ) {
        self.account = account
    }

    func perform() {
        config.schemaVersion = Config.dbMigrationSchemaVersion
        config.migrationBlock = { migration, oldSchemaVersion in
            switch oldSchemaVersion {
            case 0...32:
                migration.enumerateObjects(ofType: TokenObject.className()) { oldObject, newObject in

                    guard let oldObject = oldObject else { return }
                    guard let newObject = newObject else { return }
                    guard let value = oldObject["contract"] as? String else { return }
                    guard let address = EthereumAddress(string: value) else { return }

                    newObject["contract"] = address.description
                }
                fallthrough
            case 33...49:
                migration.deleteData(forType: Transaction.className)
                fallthrough
            case 50...52:
                migration.deleteData(forType: CoinTicker.className)
            default:
                break
            }
        }
    }
}
