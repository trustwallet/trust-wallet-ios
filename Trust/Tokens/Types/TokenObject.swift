// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift
import BigInt

enum TokenType {
    case ether
    case token
}

class TokenObject: Object {
    @objc dynamic var contract: String = ""
    @objc dynamic var name: String = ""
    @objc dynamic var symbol: String = ""
    @objc dynamic var decimals: Int = 0
    @objc dynamic var value: String = ""
    @objc dynamic var isCustom: Bool = false
    @objc dynamic var isDisabled: Bool = false
    
    convenience init(
        contract: String = "",
        name: String = "",
        symbol: String = "",
        decimals: Int = 0,
        value: String,
        isCustom: Bool = false,
        isDisabled: Bool = false,
        type: TokenType = .token
    ) {
        self.init()
        self.contract = contract.lowercased()
        self.name = name
        self.symbol = symbol
        self.decimals = decimals
        self.value = value
        self.isCustom = isCustom
        self.isDisabled = isDisabled
        self.type = type
    }

    var address: Address {
        return Address(address: contract)
    }

    var valueBigInt: BigInt {
        return BigInt(value) ?? BigInt()
    }

    var type: TokenType = .token

    override static func primaryKey() -> String? {
        return "contract"
    }

    override static func ignoredProperties() -> [String] {
        return ["type"]
    }
}
