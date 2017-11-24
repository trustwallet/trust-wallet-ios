// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BonMot

struct ExchangeTokensViewModel {

    let from: ExchangeToken
    let to: ExchangeToken

    init(
        from: ExchangeToken,
        to: ExchangeToken
    ) {
        self.from = from
        self.to = to
    }

    var fromSymbol: String {
        return from.symbol
    }

    var fromImage: UIImage? {
        return from.image
    }

    var toSymbol: String {
        return to.symbol
    }

    var toImage: UIImage? {
        return to.image
    }

    var attributedCurrency: NSAttributedString {
        let baseStyle = StringStyle(
            .lineHeightMultiple(1.2),
            .font(UIFont.systemFont(ofSize: 15))
        )
        let greenStyle = baseStyle.byAdding(.color(Colors.green))

        let conversationString = "1 \(fromSymbol) = 0.017648 \(toSymbol) ".styled(with: baseStyle)
        let percentString = "(-%)".styled(with: greenStyle)

        return (conversationString + percentString).styled(with: .alignment(.center))
    }

    var availableBalance: Double {
        return 2.22
    }

    var attributedAvailableBalance: NSAttributedString {
        return NSAttributedString(
            string: "Available \(availableBalance) \(fromSymbol)",
            attributes: [:]
        )
    }
}
