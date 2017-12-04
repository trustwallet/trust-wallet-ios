// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct ConfirmTransactionHeaderViewModel: TransactionHeaderBaseViewModel {

    private let transaction: UnconfirmedTransaction
    let config: Config
    private let fullFormatter = EtherNumberFormatter.full

    init(
        transaction: UnconfirmedTransaction,
        config: Config
    ) {
        self.transaction = transaction
        self.config = config
    }

    var amountTextColor: UIColor {
        return Colors.red
    }

    var amountAttributedString: NSAttributedString {
        switch transaction.transferType {
        case .token, .ether:
            let amount = NSAttributedString(
                string: fullFormatter.string(from: transaction.value),
                attributes: [
                    .font: UIFont.systemFont(ofSize: 28),
                    .foregroundColor: amountTextColor,
                ]
            )

            let currency = NSAttributedString(
                string: " \(transaction.transferType.symbol(server: config.server))",
                attributes: [
                    .font: UIFont.systemFont(ofSize: 20),
                ]
            )
            return amount + currency
        case .exchange(let from, let to):
            let fromAttributedString: NSAttributedString = {
                let amount = NSAttributedString(
                    string: fullFormatter.string(from: from.amount),
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 24),
                        .foregroundColor: Colors.red,
                    ]
                )

                let currency = NSAttributedString(
                    string: " " + from.token.symbol,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                    ]
                )
                return amount + currency
            }()

            let toAttributedString: NSAttributedString = {
                let amount = NSAttributedString(
                    string: fullFormatter.string(from: to.amount),
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 24),
                        .foregroundColor: Colors.green,
                    ]
                )

                let currency = NSAttributedString(
                    string: " " + to.token.symbol,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                    ]
                )
                return amount + currency
            }()

            let amount = NSAttributedString(
                string: String(" for "),
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light),
                ]
            )
            return fromAttributedString + amount + toAttributedString
        }
    }
}
