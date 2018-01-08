// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust
import TrustKeystore
import UIKit

extension ExchangeToken {
    static func make(
        name: String = "Test",
        address: Address = .make(),
        symbol: String = "TRS",
        image: UIImage? = .none,
        decimals: Int = 18
    ) -> ExchangeToken {
        return ExchangeToken(
            name: name,
            address: address,
            symbol: symbol,
            image: image,
            decimals: decimals
        )
    }
}
