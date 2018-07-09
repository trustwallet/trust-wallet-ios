// Copyright DApps Platform Inc. All rights reserved.

import RealmSwift
import Realm
import Foundation

final class NonFungibleTokenCategory: Object, Decodable {
    @objc dynamic var name: String = ""
    var items = List<NonFungibleTokenObject>()

    convenience init(
        name: String,
        items: List<NonFungibleTokenObject>
        ) {
        self.init()
        self.name = name
        self.items = items
    }

    override static func primaryKey() -> String? {
        return "name"
    }

    private enum NonFungibleTokenCategoryCodingKeys: String, CodingKey {
        case name
        case items
    }

    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NonFungibleTokenCategoryCodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let itemsArray = try container.decode([NonFungibleTokenObject].self, forKey: .items)
        let itemsList = List<NonFungibleTokenObject>()
        itemsList.append(objectsIn: itemsArray)
        self.init(name: name, items: itemsList)
    }

    required init() {
        super.init()
    }

    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }

    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
}
