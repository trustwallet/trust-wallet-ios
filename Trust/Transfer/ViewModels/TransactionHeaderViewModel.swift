// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TransactionHeaderViewModel: TransactionHeaderBaseViewModel {

    private let value: TransactionValue
    private let direction: TransactionDirection

    init(
        value: TransactionValue,
        direction: TransactionDirection
    ) {
        self.value = value
        self.direction = direction
    }

    var amountTextColor: UIColor {
        switch direction {
        case .incoming: return Colors.green
        case .outgoing: return Colors.red
        }
    }

    var amountAttributedString: NSAttributedString {
        let amount = NSAttributedString(
            string: String(value.amount),
            attributes: [
                .font: UIFont.systemFont(ofSize: 24),
                .foregroundColor: amountTextColor,
            ]
        )

        let currency = NSAttributedString(
            string: " " + value.symbol,
            attributes: [
                .font: UIFont.systemFont(ofSize: 14),
            ]
        )

        return amount + currency
    }
}
