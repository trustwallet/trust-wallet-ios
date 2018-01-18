// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

struct Token {
    let address: Address?
    let name: String
    let symbol: String
    let decimals: Int
}

extension Token {
    static func from(address: String, json: [String: AnyObject]) -> Token {
        let tokenInfo = json["tokenInfo"] as? [String: AnyObject] ?? [:]
        let addressString = tokenInfo["address"] as? String
        return Token(
            address: addressString.flatMap({ Address(string: $0) }),
            name: tokenInfo["name"] as? String ?? "",
            symbol: tokenInfo["symbol"] as? String ?? "",
            decimals: tokenInfo["decimals"] as? Int ??  Int(tokenInfo["decimals"] as? String ?? "") ?? 0
        )
    }
}
