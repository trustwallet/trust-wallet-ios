// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import UIKit

struct TransactionCellViewModel {

    private let transaction: Transaction
    private let config: Config
    private let chainState: ChainState
    private let shortFormatter = EtherNumberFormatter.short

    private let transactionViewModel: TransactionViewModel

    init(
        transaction: Transaction,
        config: Config,
        chainState: ChainState
    ) {
        self.transaction = transaction
        self.config = config
        self.chainState = chainState
        self.transactionViewModel = TransactionViewModel(
            transaction: transaction,
            config: config,
            chainState: chainState
        )
    }

    var confirmations: Int? {
        return chainState.confirmations(fromBlock: transaction.blockNumber)
    }

    private var operationTitle: String? {
        return transaction.operation?.title
    }

    var title: String {
        if let operationTitle = operationTitle { return operationTitle }
        switch transactionViewModel.state {
        case .completed:
            switch transaction.direction {
            case .incoming: return "Received"
            case .outgoing: return "Sent"
            }
        case .error: return "Error"
        case .pending:
            switch transaction.direction {
            case .incoming: return "Receiving"
            case .outgoing: return "Sending"
            }
        }
    }

    var subTitle: String {
        switch transaction.direction {
        case .incoming: return "\(transaction.from)"
        case .outgoing: return "\(transaction.to)"
        }
    }

    var subTitleTextColor: UIColor {
        return Colors.gray
    }

    var subTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.thin)
    }

    var backgroundColor: UIColor {
        switch transactionViewModel.state {
        case .completed:
            return .white
        case .error:
            return Colors.veryLightRed
        case .pending:
            return Colors.veryLightOrange
        }
    }

    var amountAttributedString: NSAttributedString {
        let value = transactionViewModel.shortValue
        let amount = NSAttributedString(
            string: transactionViewModel.amountWithSign(for: value.amount) + " " + value.symbol,
            attributes: [
                .font: UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold),
                .foregroundColor: transactionViewModel.amountTextColor,
            ]
        )
        return amount
    }

    var statusImage: UIImage? {
        switch transactionViewModel.state {
        case .error: return R.image.transaction_error()
        case .completed:
            switch transaction.direction {
            case .incoming: return R.image.transaction_received()
            case .outgoing: return R.image.transaction_sent()
            }
        case .pending:
            return R.image.transaction_pending()
        }
    }
}
