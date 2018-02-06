// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt

struct TokenViewCellViewModel {

    private let shortFormatter = EtherNumberFormatter.short

    let token: TokenObject
    let ticker: CoinTicker?

    init(
        token: TokenObject,
        ticker: CoinTicker?
    ) {
        self.token = token
        self.ticker = ticker
    }

    var title: String {
        return token.title
    }

    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: .medium)
    }

    var titleTextColor: UIColor {
        return Colors.black
    }

    var amount: String {
        return shortFormatter.string(from: BigInt(token.value) ?? BigInt(), decimals: token.decimals)
    }

    var currencyAmount: String? {
        guard let ticker = ticker else { return nil }
        let tokenValue = CurrencyFormatter.plainFormatter.string(from: token.valueBigInt, decimals: token.decimals).doubleValue
        let priceInUsd = Double(ticker.price) ?? 0
        let amount = tokenValue * priceInUsd
        guard amount > 0 else { return nil }
        return CurrencyFormatter.formatter.string(from: NSNumber(value: amount))
    }

    var percentChange: String? {
        guard let percent_change_24h = ticker?.percent_change_24h, !percent_change_24h.isEmpty else { return nil }
        return "(" + percent_change_24h + "%)"
    }

    var percentChangeColor: UIColor {
        guard let ticker = ticker else { return Colors.lightGray }
        return ticker.percent_change_24h.starts(with: "-") ? Colors.red : Colors.green
    }

    var percentChangeFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .light)
    }

    var amountTextColor: UIColor {
        return Colors.black
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    var currencyAmountTextColor: UIColor {
        return Colors.lightGray
    }

    var currencyAmountFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    var backgroundColor: UIColor {
        return .white
    }

    var placeHolder: UIImage? {
        return R.image.ethereumToken()
    }

    var imageUrl: URL? {
        return ticker?.imageURL
    }
}
