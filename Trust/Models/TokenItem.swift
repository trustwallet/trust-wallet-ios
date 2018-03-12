// Copyright SIX DAY LLC. All rights reserved.
import Foundation
import TrustKeystore

struct ERC20TokenItem: Codable {
    let address: String
    let name: String
    let symbol: String
    let decimals: Int
}

struct TokenListItem: Codable {
    let contract: ERC20TokenItem
}

extension Token {
    static func from(token: ERC20TokenItem) -> Token? {
        guard let address = Address(string: token.address) else { return .none }
        return Token(
            address: address,
            name: token.name,
            symbol: token.symbol,
            decimals: token.decimals
        )
    }
}
