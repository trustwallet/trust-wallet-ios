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

    var valueString: String {
        guard value.amount != "0" else { return value.amount }
        switch direction {
        case .incoming: return "+\(value.amount)"
        case .outgoing: return "-\(value.amount)"
        }
    }

    var amountAttributedString: NSAttributedString {
        let amount = NSAttributedString(
            string: valueString,
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
