// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct Token {
    let address: Address
    let name: String
    let symbol: String
    let totalSupply: String
    let balance: Double
    let decimals: Int
}

extension Token {
    static func from(address: String, json: [String: AnyObject]) -> Token {
        let tokenInfo = json["tokenInfo"] as? [String: AnyObject] ?? [:]
        return Token(
            address: Address(address: tokenInfo["address"] as? String ?? ""),
            name: tokenInfo["name"] as? String ?? "",
            symbol: tokenInfo["symbol"] as? String ?? "",
            totalSupply: tokenInfo["symbol"] as? String ?? "",
            balance: json["balance"] as? Double ?? 0,
            decimals: tokenInfo["decimals"] as? Int ??  Int(tokenInfo["decimals"] as? String ?? "") ?? 0
        )
    }
}
