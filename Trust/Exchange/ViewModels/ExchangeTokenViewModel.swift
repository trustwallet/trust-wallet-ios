// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt

struct ExchangeTokenViewModel {

    let token: ExchangeToken
    private let tokenFormatter = TokensFormatter()
    private let fullFormatter = EtherNumberFormatter.full

    init(token: ExchangeToken) {
        self.token = token
    }

    var nameText: String {
        return token.name
    }

    var balanceText: String {
        guard let value = token.balance else { return "0" }
        return fullFormatter.string(from: value, decimals: token.decimals)
    }

    var image: UIImage? {
        return token.image
    }

    var isEnabled: Bool {
        return true //token.balance > 0
    }

    var alpha: CGFloat {
        return isEnabled ? 1 : 0.5
    }
}
