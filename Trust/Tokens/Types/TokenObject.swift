// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift
import BigInt
import TrustCore
import Realm

struct TokenObjectList: Decodable {
    let contract: TokenObject
}

enum TokenObjectType: String {
    case coin
    case erc20
}

final class TokenObject: Object, Decodable {
    static let DEFAULT_BALANCE = 0.00

    @objc dynamic var contract: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var coinInt: Int = -1
    @objc dynamic var chainID: Int = -1
    @objc dynamic var type: String = TokenObjectType.coin.rawValue
    @objc dynamic var symbol: String = ""
    @objc dynamic var decimals: Int = 0
    @objc dynamic var value: String = ""
    @objc dynamic var isCustom: Bool = false
    @objc dynamic var isDisabled: Bool = false
    @objc dynamic var balance: Double = DEFAULT_BALANCE
    @objc dynamic var createdAt: Date = Date()

    convenience init(
        contract: String = "",
        name: String = "",
        coin: Int = -1,
        chainID: Int = -1,
        type: TokenObjectType,
        symbol: String = "",
        decimals: Int = 0,
        value: String,
        isCustom: Bool = false,
        isDisabled: Bool = false
    ) {
        self.init()
        self.contract = contract
        self.name = name
        self.coinInt = coin
        self.chainID = chainID
        self.type = type.rawValue
        self.symbol = symbol
        self.decimals = decimals
        self.value = value
        self.isCustom = isCustom
        self.isDisabled = isDisabled
    }

    private enum TokenObjectCodingKeys: String, CodingKey {
        case address
        case name
        case symbol
        case decimals
    }

    convenience required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: TokenObjectCodingKeys.self)
        var contract = try container.decode(String.self, forKey: .address)
        let name = try container.decode(String.self, forKey: .name)
        let symbol = try container.decode(String.self, forKey: .symbol)
        let decimals = try container.decode(Int.self, forKey: .decimals)
        if let convertedAddress = EthereumAddress(string: contract)?.description {
            contract = convertedAddress
        }
        self.init(contract: contract, name: name, coin: -1, chainID: -1, type: .erc20, symbol: symbol, decimals: decimals, value: "0", isCustom: false, isDisabled: false)
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

    var address: EthereumAddress {
        return EthereumAddress(string: contract)!
    }

    var valueBigInt: BigInt {
        return BigInt(value) ?? BigInt()
    }

    override static func primaryKey() -> String? {
        return "contract"
    }

    override static func ignoredProperties() -> [String] {
        return ["type"]
    }

    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? TokenObject else { return false }
        return object.contract == self.contract
    }

    var title: String {
        return name.isEmpty ? symbol : (name + " (" + symbol + ")")
    }

    var imagePath: String {
        let formatter = ImageURLFormatter()
        guard let coin = coin else {
            return formatter.image(for: contract)
        }
        return formatter.image(for: coin)
    }

    var imageURL: URL? {
        return URL(string: imagePath)
    }

    var displayName: String {
        return "\(self.name) (\(self.symbol))"
    }

    var contractAddress: EthereumAddress {
        return EthereumAddress(string: contract)!
    }

    var coin: Coin? {
        return Coin(rawValue: coinInt)
    }

    var isCoin: Bool {
        return coin != nil
    }

    var tokenType: TokenObjectType {
        return TokenObjectType(rawValue: type) ?? .coin
    }
}
