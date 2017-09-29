// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TransactionViewModel {

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    let transaction: Transaction

    init(transaction: Transaction) {
        self.transaction = transaction
    }

    var title: String {
        return "Transaction"
    }

    var backgroundColor: UIColor {
        return .white
    }

    var amount: String {
        let value = EthereumConverter.from(value: transaction.value, to: .ether, minimumFractionDigits: 3)
        switch transaction.direction {
        case .incoming: return "+\(value)"
        case .outgoing: return "-\(value)"
        }
    }

    var amountTextColor: UIColor {
        switch transaction.direction {
        case .incoming: return Colors.green
        case .outgoing: return Colors.red
        }
    }

    var amountAttributedString: NSAttributedString {
        let amount = NSAttributedString(
            string: self.amount,
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 20),
                NSForegroundColorAttributeName: amountTextColor,
            ]
        )

        let currency = NSAttributedString(
            string: " ether",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14),
            ]
        )

        return amount + currency
    }

    var createdAt: String {
        return TransactionViewModel.formatter.string(from: transaction.time)
    }
}
