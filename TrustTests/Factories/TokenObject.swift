// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust
import TrustCore

extension TokenObject {
    static func make() -> TokenObject {
        return TokenObject(
            contract: EthereumAddress.zero.description,
            name: "Viktor",
            coin: .ethereum,
            type: .coin,
            symbol: "VIK",
            value: ""
        )
    }
}
