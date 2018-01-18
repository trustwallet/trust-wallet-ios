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
        chainState: ChainState,
        currentWallet: Wallet
    ) {
        self.transaction = transaction
        self.config = config
        self.chainState = chainState
        self.transactionViewModel = TransactionViewModel(
            transaction: transaction,
            config: config,
            chainState: chainState,
            currentWallet: currentWallet
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
        case .main, .classic, .poa, .kovan, .ropsten, .sokol: return true
        }
    }

    var shareAvailable: Bool {
        return detailsAvailable
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
        let gasLimit = BigInt(transaction.gas) ?? BigInt()
        let gasFee: BigInt = {
            switch transaction.state {
            case .completed, .error: return gasPrice * gasUsed
            case .pending, .unknown: return gasPrice * gasLimit
            }
        }()
        return fullFormatter.string(from: gasFee) + " " + config.server.symbol
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
