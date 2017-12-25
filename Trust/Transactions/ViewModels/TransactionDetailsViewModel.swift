// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import UIKit

struct TransactionDetailsViewModel {

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .medium
        formatter.timeZone = TimeZone.current
        return formatter
    }()

    private let transactionViewModel: TransactionViewModel

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
        self.transactionViewModel = TransactionViewModel(
            transaction: transaction,
            config: config,
            chainState: chainState
        )
    }

    var title: String {
        return "Transaction"
    }

    var backgroundColor: UIColor {
        return .white
    }

    var createdAt: String {
        return TransactionDetailsViewModel.dateFormatter.string(from: transaction.date)
    }

    var detailsAvailable: Bool {
        switch config.server {
        case .main, .classic, .kovan, .ropsten: return true
        case .poa: return false
        }
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

    var amountAttributedString: NSAttributedString {
        return transactionViewModel.fullAmountAttributedString
    }

    var shareItem: URL {
        return detailsURL
    }
}
