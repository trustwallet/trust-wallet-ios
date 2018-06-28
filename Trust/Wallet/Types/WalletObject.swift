// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import Realm

class WalletObject: Object {

    @objc dynamic var id: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    static func from(_ wallet: Wallet) -> WalletObject {
        let info = WalletObject()
        info.id = wallet.description
        return info
    }
}
