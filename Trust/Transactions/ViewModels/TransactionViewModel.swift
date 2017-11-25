// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TransactionValue {
    let amount: String
    let symbol: String
}

struct TransactionViewModel {

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    let transaction: Transaction
    let config: Config
    let chainState: ChainState

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
        if let amount = transaction.operation?.value, let symbol = transaction.operation?.symbol {
            return TransactionValue(amount: amount, symbol: symbol)
        }
        return TransactionValue(
            amount: EthereumConverter.from(value: BInt(transaction.value), to: .ether, minimumFractionDigits: 5),
            symbol: config.server.symbol
        )
    }

    var createdAt: String {
        return TransactionViewModel.formatter.string(from: transaction.date)
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
        let gasUsed = BInt(String(transaction.gasUsed))
        let gasPrice = BInt(String(transaction.gasPrice))
        return EthereumConverter.from(
            value: gasPrice * gasUsed,
            to: .ether,
            minimumFractionDigits: 5,
            maximumFractionDigits: 5
        )
    }

    var confirmation: String {
        let confirmation = chainState.latestBlock - Int(transaction.blockNumber)
        return String(max(0, confirmation))
    }

    var blockNumber: String {
        return String(transaction.blockNumber)
    }
}
