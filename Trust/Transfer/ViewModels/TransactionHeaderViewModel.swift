// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TransactionHeaderViewModel: TransactionHeaderBaseViewModel {

    private let amount: Double
    private let direction: TransactionDirection

    init(
        amount: Double,
        direction: TransactionDirection
    ) {
        self.amount = amount
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
            string: String(self.amount),
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 24),
                NSForegroundColorAttributeName: amountTextColor,
            ]
        )

        let currency = NSAttributedString(
            string: " ETH",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 14),
            ]
        )

        return amount + currency
    }
}
