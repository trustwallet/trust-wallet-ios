// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt
import TrustKeystore

struct ExchangeToken {
    let name: String
    let address: Address
    let symbol: String
    let image: UIImage?
    let balance: BigInt?
    let decimals: Int

    init(
        name: String,
        address: Address,
        symbol: String,
        image: UIImage?,
        balance: BigInt? = nil,
        decimals: Int
    ) {
        self.name = name
        self.address = address
        self.symbol = symbol
        self.image = image
        self.balance = balance
        self.decimals = decimals
    }
}

extension ExchangeToken: Equatable {
    static func == (lhs: ExchangeToken, rhs: ExchangeToken) -> Bool {
        return lhs.symbol == rhs.symbol
    }
}
