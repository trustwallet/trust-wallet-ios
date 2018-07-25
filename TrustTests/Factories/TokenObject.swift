// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore

extension TokenObject {
    static func make(
        contract: Address = EthereumAddress.zero,
        name: String = "Viktor",
        coin: Coin = .ethereum,
        type: TokenObjectType = .coin,
        symbol: String = "VIK",
        value: String = ""
    ) -> TokenObject {
        return TokenObject(
            contract: contract.description,
            name: name,
            coin: coin,
            type: type,
            symbol: symbol,
            value: value
        )
    }
}
