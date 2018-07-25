// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import BigInt

struct TokenViewCellViewModel {

    private let shortFormatter = EtherNumberFormatter.short
    let viewModel: TokenObjectViewModel
    private let ticker: CoinTicker?
    let store: TransactionsStorage

    init(
        viewModel: TokenObjectViewModel,
        ticker: CoinTicker?,
        store: TransactionsStorage
    ) {
        self.viewModel = viewModel
        self.ticker = ticker
        self.store = store
    }

    var title: String {
        return viewModel.title
    }

    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    var titleTextColor: UIColor {
        return Colors.black
    }

    var amount: String {
        return shortFormatter.string(from: BigInt(viewModel.token.value) ?? BigInt(), decimals: viewModel.token.decimals)
    }

    var currencyAmount: String? {
        return TokensLayout.cell.totalFiatAmount(token: viewModel.token)
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: .medium)
    }

    var currencyAmountFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .regular)
    }

    var backgroundColor: UIColor {
        return .white
    }

    var amountTextColor: UIColor {
        return Colors.black
    }

    var currencyAmountTextColor: UIColor {
        return Colors.lightGray
    }

    // Percent change

    var percentChange: String? {
        return TokensLayout.cell.percentChange(for: ticker)
    }

    var percentChangeColor: UIColor {
        return TokensLayout.cell.percentChangeColor(for: ticker)
    }

    var percentChangeFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .light)
    }

    var placeholderImage: UIImage? {
        return viewModel.placeholder
    }

    // Market Price

    var marketPriceFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: .regular)
    }

    var marketPriceTextColor: UIColor {
        return Colors.lightGray
    }

    var marketPrice: String? {
        return TokensLayout.cell.marketPrice(for: ticker)
    }

    var imageURL: URL? {
        return viewModel.imageURL
    }
}
