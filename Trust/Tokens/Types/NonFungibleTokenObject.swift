// Copyright SIX DAY LLC. All rights reserved.

import RealmSwift
import BigInt

class NonFungibleTokenObject: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var uniqueID: String = ""
    @objc dynamic var contract: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var annotation: String = ""
    @objc dynamic var imagePath: String = ""
    @objc dynamic var externalPath: String = ""

    convenience init(
        id: String,
        contract: String,
        name: String,
        annotation: String,
        imagePath: String,
        externalPath: String
    ) {
        self.init()
        self.uniqueID = id + contract
    }

    override static func primaryKey() -> String? {
        return "uniqueID"
    }
}
