// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct BalanceTokenViewModel: BalanceBaseViewModel {

    let token: Token

    var attributedAmount: NSAttributedString {
        return NSAttributedString(
            string: "\(token.amount) \(token.symbol)",
            attributes: largeLabelAttributed
        )
    }

    var attributedCurrencyAmount: NSAttributedString? {
        return nil
    }
}
