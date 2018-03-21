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
        static let amountTextColor = Colors.black
        static let currencyAmountTextColor = Colors.lightGray
        static let fiatAmountTextColor = Colors.gray

        static func percentChangeColor(for ticker: CoinTicker?) -> UIColor {
            guard let ticker = ticker else { return Colors.lightGray }
            return ticker.percent_change_24h.starts(with: "-") ? Colors.red : Colors.green
        }

        static func percentChange(for ticker: CoinTicker?) -> String? {
            guard let percent_change_24h = ticker?.percent_change_24h, !percent_change_24h.isEmpty else { return nil }
            return "(" + percent_change_24h + "%)"
        }

        static func totalFiatAmount(for ticker: CoinTicker?, token: TokenObject) -> String? {
            guard let ticker = ticker else { return nil }
            let tokenValue = CurrencyFormatter.plainFormatter.string(from: token.valueBigInt, decimals: token.decimals).doubleValue
            let priceInUsd = Double(ticker.price) ?? 0
            let amount = tokenValue * priceInUsd
            guard amount > 0 else { return nil }
            return CurrencyFormatter.formatter.string(from: NSNumber(value: amount))
        }

        static func currencyAmount(for ticker: CoinTicker?, token: TokenObject) -> String? {
            guard let ticker = ticker, let price = Double(ticker.price), price > 0 else { return .none }
            return CurrencyFormatter.formatter.string(from: NSNumber(value: price))
        }
    }
}
