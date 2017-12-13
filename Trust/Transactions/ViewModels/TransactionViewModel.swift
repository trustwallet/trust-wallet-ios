// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import UIKit

struct TransactionValue {
    let amount: String
    let symbol: String
}

struct TransactionViewModel {

    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    let transaction: Transaction
    let config: Config
    let chainState: ChainState
    let shortFormatter = EtherNumberFormatter.short
    let fullFormatter = EtherNumberFormatter.full

    init(
        transaction: Transaction,
        config: Config,
        chainState: ChainState
    ) {
        self.transaction = transaction
        self.config = config
        self.chainState = chainState
    }

    var title: String {
        return "Transaction"
    }

    var backgroundColor: UIColor {
        return .white
    }

    var value: TransactionValue {
        return transactionValue(for: shortFormatter)
    }

    var createdAt: String {
        return TransactionViewModel.dateFormatter.string(from: transaction.date)
    }

    var detailsURL: URL {
        return ConfigExplorer(server: config.server).transactionURL(for: transaction.id)
    }

    var transactionID: String {
        return transaction.id
    }

    var to: String {
        guard let to = transaction.operation?.to else {
            return transaction.to
        }
        return to
    }

    var from: String {
        return transaction.from
    }

    var gasFee: String {
        let gasUsed = BigInt(transaction.gasUsed) ?? BigInt()
        let gasPrice = BigInt(transaction.gasPrice) ?? BigInt()
        return fullFormatter.string(from: gasPrice * gasUsed)
    }

    var confirmation: String {
        guard let confirmation = chainState.confirmations(fromBlock: transaction.blockNumber) else {
            return "--"
        }
        return String(confirmation)
    }

    var blockNumber: String {
        return String(transaction.blockNumber)
    }

    var amountTextColor: UIColor {
        switch transaction.direction {
        case .incoming: return Colors.green
        case .outgoing: return Colors.red
        }
    }

    var valueString: String {
        guard value.amount != "0" else { return value.amount }
        switch transaction.direction {
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

    private func transactionValue(for formatter: EtherNumberFormatter) -> TransactionValue {
        if let operation = transaction.operation, let symbol = operation.symbol {
            return TransactionValue(
                amount: formatter.string(from: BigInt(operation.value) ?? BigInt(), decimals: operation.decimals),
                symbol: symbol
            )
        }
        return TransactionValue(
            amount: fullFormatter.string(from: BigInt(transaction.value) ?? BigInt()),
            symbol: config.server.symbol
        )
    }
}
