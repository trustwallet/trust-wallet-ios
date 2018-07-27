// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift
import Realm
import TrustCore

final class WalletObject: Object {

    @objc dynamic var id: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var completedBackup: Bool = false
    @objc dynamic var mainWallet: Bool = false
    @objc dynamic var balance: String = ""

    override static func primaryKey() -> String? {
        return "id"
    }

    static func from(_ type: WalletType) -> WalletObject {
        let info = WalletObject()
        info.id = type.description
        return info
    }
}
