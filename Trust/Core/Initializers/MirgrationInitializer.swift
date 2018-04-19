// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustCore

class MigrationInitializer: Initializer {

    let account: Wallet
    let chainID: Int
    lazy var config: Realm.Configuration = {
        return RealmConfiguration.configuration(for: account, chainID: chainID)
    }()

    init(
        account: Wallet, chainID: Int
    ) {
        self.account = account
        self.chainID = chainID
    }

    func perform() {
        config.schemaVersion = 50
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
                MigrationInitializer.migrateTokenObjectBalanceField(migration)
            default:
                break
            }
        }
    }

    static func migrateTokenObjectBalanceField(_ migration: Migration) {
        migration.enumerateObjects(ofType: TokenObject.className()) { oldObject, newObject in
            let newFieldName = "balance"
            let fieldExistAlready = oldObject?.objectSchema.properties.contains(where: { $0.name == newFieldName }) ?? false
            if !fieldExistAlready {
                newObject?[newFieldName] = TokenObject.DEFAULT_BALANCE
            }
        }
    }
}
