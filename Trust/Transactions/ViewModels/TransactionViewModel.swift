// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import BigInt
import TrustKeystore

struct TransactionViewModel {

    private let transaction: Transaction
    private let config: Config
    private let currentAccount: Account
    private let shortFormatter = EtherNumberFormatter.short
    private let balanceFormatter = EtherNumberFormatter.balance
    private let fullFormatter = EtherNumberFormatter.full
    private let server: RPCServer
    private let token: TokenObject

    init(
        transaction: Transaction,
        config: Config,
        currentAccount: Account,
        server: RPCServer,
        token: TokenObject
    ) {
        self.transaction = transaction
        self.config = config
        self.currentAccount = currentAccount
        self.server = server
        self.token = token
    }

    var transactionFrom: String {
        switch token.type {
        case .coin: return transaction.from
        case .ERC20: return transaction.operation?.from ?? transaction.from
        }
    }

    var transactionTo: String {
        switch token.type {
        case .coin: return transaction.to
        case .ERC20: return transaction.operation?.to ?? transaction.to
        }
    }

    var direction: TransactionDirection {
        if currentAccount.address.description == transactionTo || currentAccount.address.description.lowercased() == transactionTo.lowercased() {
            return .incoming
        }
        return .outgoing
    }

    var amountTextColor: UIColor {
        switch direction {
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

    func amountWithSign(for amount: String) -> String {
        guard amount != "0" else { return amount }
        switch direction {
        case .incoming: return "+\(amount)"
        case .outgoing: return "-\(amount)"
        }
    }

    private func transactionValue(for formatter: EtherNumberFormatter) -> TransactionValue {
        switch token.type {
        case .coin:
            return transactionValue
        case .ERC20:
            if let operation = transaction.operation, let symbol = operation.symbol {
                return TransactionValue(
                    amount: formatter.string(from: BigInt(operation.value) ?? BigInt(), decimals: operation.decimals),
                    symbol: symbol
                )
            }
            return transactionValue
        }
    }

    private var transactionValue: TransactionValue {
        return TransactionValue(
            amount: EtherNumberFormatter.short.string(from: BigInt(transaction.value) ?? BigInt()),
            symbol: server.symbol
        )
    }

    var statusImage: UIImage? {
        switch transaction.state {
        case .error, .unknown, .failed, .deleted:
            return R.image.transaction_error()
        case .completed:
            switch direction {
            case .incoming:
                return R.image.transaction_received()
            case .outgoing:
                return R.image.transaction_sent()
            }
        case .pending:
            return R.image.transaction_pending()
        }
    }

    var amountText: String {
        let value = shortValue
        return amountWithSign(for: value.amount) + " " + value.symbol
    }

    var amountFullText: String {
        let value = transactionValue(for: balanceFormatter)
        return amountWithSign(for: value.amount) + " " + value.symbol
    }
}
