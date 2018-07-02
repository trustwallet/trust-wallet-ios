// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import Realm

class WalletObject: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    static func from(_ wallet: Wallet) -> WalletObject {
        let info = WalletObject()
        info.id = wallet.primaryKey
        return info
    }
}

extension Wallet {
    var primaryKey: String {
        return description
    }
}
