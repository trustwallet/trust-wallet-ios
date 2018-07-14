// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift
import Realm

final class WalletObject: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var completedBackup: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }

    static func from(_ wallet: WalletStruct) -> WalletObject {
        let info = WalletObject()
        info.id = wallet.primaryKey
        return info
    }
}

extension WalletStruct {
    var primaryKey: String {
        return description
    }
}
