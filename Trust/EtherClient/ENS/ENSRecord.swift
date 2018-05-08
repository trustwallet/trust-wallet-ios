// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class ENSRecord: Object {

    @objc dynamic var name: String = ""
    @objc dynamic var owner: String = ""
    @objc dynamic var resolver: String = ""
    @objc dynamic var ttl: Int = 0

    @objc dynamic var updatedAt: Date = Date()
    @objc dynamic var isReverse: Bool = false

    convenience init(name: String, owner: String, isReverse: Bool = false, updatedAt: Date = Date()) {
        self.init()
        self.name = name
        self.owner = owner
        self.updatedAt = updatedAt
        self.isReverse = isReverse
    }

    override class func primaryKey() -> String? {
        return "name"
    }
}
