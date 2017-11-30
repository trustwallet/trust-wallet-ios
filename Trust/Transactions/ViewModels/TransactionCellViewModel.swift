// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import UIKit

struct TransactionCellViewModel {

    let transaction: Transaction
    let chainState: ChainState
    let formatter = EtherNumberFormatter.short

    init(
        transaction: Transaction,
        chainState: ChainState
    ) {
        self.transaction = transaction
        self.chainState = chainState
    }

    var confirmations: Int {
        return max(chainState.latestBlock - Int(transaction.blockNumber), 0)
    }

    var state: TransactionState {
        if transaction.isError {
            return .error
        }
        if confirmations <= 0 && chainState.latestBlock >= transaction.blockNumber {
            return .pending
        }
        return .completed
    }

    private var operationTitle: String? {
        return transaction.operation?.title
    }

    private var operationValue: String? {
        return transaction.operation?.value
    }

    var title: String {
        if let operationTitle = operationTitle { return operationTitle }
        switch state {
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

    var amount: String {
        let value: String = {
            if let operationValue = operationValue {
                return operationValue
            }
            let number = BigInt(transaction.value) ?? BigInt()
            return formatter.string(from: number)
        }()
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

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
    }

    var backgroundColor: UIColor {
        switch state {
        case .completed:
            return .white
        case .error:
            return Colors.veryLightRed
        case .pending:
            return Colors.veryLightOrange
        }
    }

    var statusImage: UIImage? {
        switch state {
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
