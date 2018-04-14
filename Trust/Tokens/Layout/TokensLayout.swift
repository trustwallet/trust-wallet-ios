// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TokensLayout {
    struct tableView {
        static let height: CGFloat = 84
        static let separatorColor = UIColor(hex: "d7d7d7")
        static let layoutInsets = UIEdgeInsets(top: 0, left: 86, bottom: 0, right: 0)
    }

    struct cell {
        static var imageSize: CGFloat {
            return 54
            // TODO: return 44 for 2 scale, same for xib file.
            //if UIScreen.main.scale == 3 { return 54 }
            //return 44
        }
        static let amountTextColor = Colors.black
        static let currencyAmountTextColor = Colors.lightGray
        static let fiatAmountTextColor = Colors.gray

        static func percentChangeColor(for ticker: CoinTickerObject?) -> UIColor {
            guard let ticker = ticker else { return Colors.lightGray }
            return ticker.percent_change_24h.starts(with: "-") ? Colors.red : Colors.green
        }

        static func percentChange(for ticker: CoinTickerObject?) -> String? {
            guard let percent_change_24h = ticker?.percent_change_24h, !percent_change_24h.isEmpty else { return nil }
            return "(" + percent_change_24h + "%)"
        }

        static func totalFiatAmount(token: TokenObject) -> String? {
            return CurrencyFormatter.formatter.string(from: NSNumber(value: token.balance))
        }

        static func currencyAmount(for ticker: CoinTickerObject?, token: TokenObject) -> String? {
            guard let ticker = ticker, let price = Double(ticker.price), price > 0 else { return .none }
            return CurrencyFormatter.formatter.string(from: NSNumber(value: price))
        }
    }
}
