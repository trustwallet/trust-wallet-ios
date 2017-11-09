// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct ConfirmTransactionHeaderViewModel: TransactionHeaderBaseViewModel {

    private let transaction: UnconfirmedTransaction

    init(
        transaction: UnconfirmedTransaction
    ) {
        self.transaction = transaction
    }

    var amountTextColor: UIColor {
        return Colors.red
    }

    var amountAttributedString: NSAttributedString {
        let amount = NSAttributedString(
            string: String(transaction.amount),
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 28),
                NSForegroundColorAttributeName: amountTextColor,
            ]
        )

        let currency = NSAttributedString(
            string: " \(transaction.transferType.symbol)",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 20),
            ]
        )

        return amount + currency
    }
}
