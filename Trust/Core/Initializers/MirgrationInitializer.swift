// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustCore

class MigrationInitializer: Initializer {

    let account: Wallet
    let chainID: Int
    private let schemaVersion = Config.dbMigrationSchemaVersion
    lazy var config: Realm.Configuration = {
        return RealmConfiguration.configuration(for: account, chainID: chainID, with: schemaVersion)
    }()

    init(
        account: Wallet, chainID: Int
    ) {
        self.account = account
        self.chainID = chainID
    }

    func perform() {
        config.schemaVersion = schemaVersion
        config.migrationBlock = { migration, oldSchemaVersion in
            switch oldSchemaVersion {
            case 0...32:
                migration.enumerateObjects(ofType: TokenObject.className()) { oldObject, newObject in

                    guard let oldObject = oldObject else { return }
                    guard let newObject = newObject else { return }
                    guard let value = oldObject["contract"] as? String else { return }
                    guard let address = Address(string: value) else { return }

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
