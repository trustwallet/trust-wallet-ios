// Copyright SIX DAY LLC. All rights reserved.

import RealmSwift
import BigInt

class NonFungibleTokenObject: Object {
    @objc dynamic var type: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var annotation: String = ""
    @objc dynamic var imagePath: String = ""
    @objc dynamic var externalPath: String = ""
}
