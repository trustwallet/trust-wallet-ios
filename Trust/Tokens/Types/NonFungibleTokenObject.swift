// Copyright SIX DAY LLC. All rights reserved.

import RealmSwift
import Realm
import BigInt

class NonFungibleTokenObject: Object, Decodable {
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
        self.id = id
        self.contract = contract
        self.name = name
        self.annotation = annotation
        self.imagePath = imagePath
        self.externalPath = externalPath
        self.uniqueID = id + contract
    }

    override static func primaryKey() -> String? {
        return "uniqueID"
    }
    
    private enum NonFungibleTokenCodingKeys: String, CodingKey {
        case id = "token_id"
        case contract = "contract_address"
        case name = "name"
        case annotation = "description"
        case imagePath = "image_url"
        case externalPath = "external_link"
    }

    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: NonFungibleTokenCodingKeys.self)
        let id = try container.decodeIfPresent(String.self, forKey: .id)  ?? ""
        let contract = try container.decodeIfPresent(String.self, forKey: .contract)  ?? ""
        let name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        let annotation = try container.decodeIfPresent(String.self, forKey: .annotation) ?? ""
        let imagePath = try container.decodeIfPresent(String.self, forKey: .imagePath) ?? ""
        let externalPath = try container.decodeIfPresent(String.self, forKey: .externalPath) ?? ""
        self.init(id: id, contract: contract, name: name, annotation: annotation, imagePath: imagePath, externalPath: externalPath)
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

    var extentalURL: URL? {
        return URL(string: externalPath)
    }
}
