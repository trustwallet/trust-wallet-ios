// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TokensViewModel {

    var tokens: [TokenObject] = []
    var tickers: [String: CoinTicker]?

    init(
        tokens: [TokenObject],
        tickers: [String: CoinTicker]?
    ) {
        self.tokens = tokens
        self.tickers = tickers
    }

    var amount: String? {
        var totalAmount: Double = 0
        tokens.forEach { token in
            totalAmount += amount(for: token)
        }
        return CurrencyFormatter.formatter.string(from: NSNumber(value: totalAmount))
    }

    private func amount(for token: TokenObject) -> Double {
        guard let tickers = tickers else { return 0 }
        guard !token.valueBigInt.isZero, let price = tickers[token.symbol] else { return 0 }
        let tokenValue = CurrencyFormatter.plainFormatter.string(from: token.valueBigInt, decimals: token.decimals).doubleValue
        return tokenValue * price.priceUSD
    }

    var headerBalance: String {
        return amount ?? "--"
    }

    var headerBalanceTextColor: UIColor {
        return Colors.black
    }

    var headerBackgroundColor: UIColor {
        return .white
    }

    var headerBalanceFont: UIFont {
        return UIFont.systemFont(ofSize: 26, weight: .medium)
    }

    var title: String {
        return NSLocalizedString("tokens.navigation.title", value: "Tokens", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }

    var hasContent: Bool {
        return !tokens.isEmpty
    }

    var numberOfSections: Int {
        return 1
    }

    func numberOfItems(for section: Int) -> Int {
        return tokens.count
    }

    func item(for row: Int, section: Int) -> TokenObject {
        return tokens[row]
    }

    func ticker(for token: TokenObject) -> CoinTicker? {
        return tickers?[token.symbol]
    }

    func canDelete(for row: Int, section: Int) -> Bool {
        let token = item(for: row, section: section)
        return token.isCustom
    }

    var footerTitle: String {
        return NSLocalizedString("tokens.footer.label.title", value: "Missing token?", comment: "")
    }

    var footerTextColor: UIColor {
        return Colors.black
    }

    var footerTextFont: UIFont {
        return UIFont.systemFont(ofSize: 14, weight: .light)
    }
}
