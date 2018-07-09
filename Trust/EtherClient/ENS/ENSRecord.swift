// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift

final class ENSRecord: Object {

    @objc dynamic var name: String = ""
    @objc dynamic var owner: String = ""
    @objc dynamic var resolver: String = ""
    @objc dynamic var address: String = ""
    @objc dynamic var ttl: Int = 0

    @objc dynamic var updatedAt: Date = Date()
    @objc dynamic var isReverse: Bool = false

    convenience init(name: String, address: String, owner: String = "", resolver: String = "", isReverse: Bool = false, updatedAt: Date = Date()) {
        self.init()
        self.name = name
        self.owner = owner
        self.address = address
        self.resolver = resolver
        self.updatedAt = updatedAt
        self.isReverse = isReverse
    }

    override class func primaryKey() -> String? {
        return "name"
    }
}
