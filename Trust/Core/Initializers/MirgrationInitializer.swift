// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import TrustKeystore

class MigrationInitializer: Initializer {

    let account: Wallet
    let chainID: Int

    init(
        account: Wallet, chainID: Int
    ) {
        self.account = account
        self.chainID = chainID
    }

    func perform() {
        var config = RealmConfiguration.configuration(for: account, chainID: chainID)
        config.schemaVersion = 36
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
            default: break
            }
        }
        Realm.Configuration.defaultConfiguration = config
    }
}
