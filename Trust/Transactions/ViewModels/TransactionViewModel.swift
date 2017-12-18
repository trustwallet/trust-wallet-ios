// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt

struct TransactionViewModel {

    private let transaction: Transaction
    private let config: Config
    private let chainState: ChainState
    private let shortFormatter = EtherNumberFormatter.short
    private let fullFormatter = EtherNumberFormatter.full

    init(
        transaction: Transaction,
        config: Config,
        chainState: ChainState
    ) {
        self.transaction = transaction
        self.config = config
        self.chainState = chainState
    }

    var confirmations: Int? {
        return chainState.confirmations(fromBlock: transaction.blockNumber)
    }

    var state: TransactionState {
        if transaction.isError {
            return .error
        }
        if confirmations == 0 {
            return .pending
        }
        return .completed
    }

    var amountTextColor: UIColor {
        switch transaction.direction {
        case .incoming: return Colors.green
        case .outgoing: return Colors.red
        }
    }

    var shortValue: TransactionValue {
        return transactionValue(for: shortFormatter)
    }

    var fullValue: TransactionValue {
        return transactionValue(for: fullFormatter)
    }

    var shortAmountAttributedString: NSAttributedString {
        return amountAttributedString(for: shortValue)
    }

    var fullAmountAttributedString: NSAttributedString {
        return amountAttributedString(for: fullValue)
    }

    func amountAttributedString(for value: TransactionValue) -> NSAttributedString {
        let amount = NSAttributedString(
            string: amountWithSign(for: value.amount),
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

    func amountWithSign(for amount: String) -> String {
        guard amount != "0" else { return amount }
        switch transaction.direction {
        case .incoming: return "+\(amount)"
        case .outgoing: return "-\(amount)"
        }
    }

    private func transactionValue(for formatter: EtherNumberFormatter) -> TransactionValue {
        if let operation = transaction.operation, let symbol = operation.symbol {
            return TransactionValue(
                amount: formatter.string(from: BigInt(operation.value) ?? BigInt(), decimals: operation.decimals),
                symbol: symbol
            )
        }
        return TransactionValue(
            amount: formatter.string(from: BigInt(transaction.value) ?? BigInt()),
            symbol: config.server.symbol
        )
    }
}
