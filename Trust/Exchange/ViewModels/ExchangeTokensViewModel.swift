// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BonMot

struct ExchangeTokenRate {
    let rate: String
}

struct TokensFormatter {
    static let formatter = EtherNumberFormatter.full

    static func from(token: ExchangeToken, amount: String) -> String? {
        return formatter.number(from: amount, decimals: token.decimals)?.description
    }
}

struct ExchangeTokensViewModel {

    let from: ExchangeToken
    let to: ExchangeToken
    private let tokenRate: ExchangeTokenRate?
    let balance: BalanceProtocol?

    private static let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 3
        numberFormatter.maximumFractionDigits = 3
        numberFormatter.usesSignificantDigits = true
        return numberFormatter
    }()

    init(
        from: ExchangeToken,
        to: ExchangeToken,
        tokenRate: ExchangeTokenRate? = .none,
        fromValue: Double? = .none,
        toValue: Double? = .none,
        balance: BalanceProtocol? = .none
    ) {
        self.from = from
        self.to = to
        self.tokenRate = tokenRate
        self.balance = balance
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

    var rateDouble: Double? {
        return rateNumber?.doubleValue
    }

    var rateNumber: NSNumber? {
        guard let tokenRate = tokenRate else {
            return .none
        }
        let res = pow(10.0, Double(from.decimals))
        return NSNumber(value: (Double(tokenRate.rate) ?? 0) / res)
    }

    var attributedCurrency: NSAttributedString {
        guard let rateDouble = rateNumber else {
            return NSAttributedString(string: "...")
        }
        guard rateDouble != 0 else {
            return NSAttributedString(string: "Unavailable")
        }
        guard let rate = ExchangeTokensViewModel.numberFormatter.string(from: rateDouble) else {
            return NSAttributedString(string: "Undefined")
        }
        let baseStyle = StringStyle(
            .lineHeightMultiple(1.2),
            .font(UIFont.systemFont(ofSize: 15))
        )
        let greenStyle = baseStyle.byAdding(.color(Colors.green))

        let conversationString = "1 \(fromSymbol) = \(rate) \(toSymbol) ".styled(with: baseStyle)
        let percentString = "(-%)".styled(with: greenStyle)

        return (conversationString + percentString).styled(with: .alignment(.center))
    }

    var availableBalance: String {
        guard let balance = balance else { return "" }
        return balance.amountFull
    }

    var attributedAvailableBalance: NSAttributedString {
        guard !availableBalance.isEmpty else {
            return NSAttributedString(string: "...")
        }

        let baseStyle = StringStyle(
            .lineHeightMultiple(1.2),
            .font(UIFont.systemFont(ofSize: 15))
        )
        let balanceAvailable = EtherNumberFormatter.full.string(from: balance!.value, units: .ether)

        let percentString = "Available: ".styled(with: baseStyle.byAdding(.color(Colors.black)))
        let conversationString = "\(balanceAvailable) \(fromSymbol)".styled(with: baseStyle.byAdding(.color(Colors.green)))

        return percentString + conversationString.styled(with: .alignment(.right))
    }
}
