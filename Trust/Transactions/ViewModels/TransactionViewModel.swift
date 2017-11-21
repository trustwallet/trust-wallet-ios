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

    init(
        transaction: Transaction,
        config: Config
    ) {
        self.transaction = transaction
        self.config = config
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
}
