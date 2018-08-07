// Copyright DApps Platform Inc. All rights reserved.

import RealmSwift
import Realm
import Foundation

final class CollectibleTokenCategory: Object, Decodable {
    @objc dynamic var name: String = ""
    var items = List<CollectibleTokenObject>()

    convenience init(
        name: String,
        items: List<CollectibleTokenObject>
    ) {
        self.init()
        self.name = name
        self.items = items
    }

    override static func primaryKey() -> String? {
        return "name"
    }

    private enum CollectibleTokenCategoryCodingKeys: String, CodingKey {
        case name
        case items
    }

    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CollectibleTokenCategoryCodingKeys.self)
        let name = try container.decode(String.self, forKey: .name)
        let itemsArray = try container.decode([CollectibleTokenObject].self, forKey: .items)
        let itemsList = List<CollectibleTokenObject>()
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
