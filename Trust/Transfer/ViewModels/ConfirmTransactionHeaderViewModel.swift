// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct ConfirmTransactionHeaderViewModel: TransactionHeaderBaseViewModel {

    private let transaction: UnconfirmedTransaction
    let config: Config

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
        let amount = NSAttributedString(
            string: String(transaction.amount),
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 28),
                NSForegroundColorAttributeName: amountTextColor,
            ]
        )

        let currency = NSAttributedString(
            string: " \(transaction.transferType.symbol(server: config.server))",
            attributes: [
                NSFontAttributeName: UIFont.systemFont(ofSize: 20),
            ]
        )

        return amount + currency
    }
}
