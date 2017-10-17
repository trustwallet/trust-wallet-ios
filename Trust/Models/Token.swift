// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct Token {
    let address: Address
    let name: String
    let symbol: String
    let totalSupply: String
    let balance: Double
    let decimals: Int64
}

extension Token {
    static func from(address: String, json: [String: AnyObject]) -> Token {
        let tokenInfo = json["tokenInfo"] as? [String: AnyObject] ?? [:]
        return Token(
            address: Address(address: address),
            name: tokenInfo["name"] as? String ?? "",
            symbol: tokenInfo["symbol"] as? String ?? "",
            totalSupply: tokenInfo["symbol"] as? String ?? "",
            balance: json["balance"] as? Double ?? 0,
            decimals: tokenInfo["decimals"] as? Int64 ??  Int64(tokenInfo["decimals"] as? String ?? "") ?? 0
        )
    }
}
