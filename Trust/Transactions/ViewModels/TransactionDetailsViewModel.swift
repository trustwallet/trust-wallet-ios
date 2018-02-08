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
    private let currencyRate: CurrencyRate?

    init(
        transaction: Transaction,
        config: Config,
        chainState: ChainState,
        currentWallet: Wallet,
        currencyRate: CurrencyRate?
    ) {
        self.transaction = transaction
        self.config = config
        self.chainState = chainState
        self.currencyRate = currencyRate
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

    var createdAtLabelTitle: String {
        return NSLocalizedString("transaction.time.label.title", value: "Transaction time", comment: "")
    }

    var detailsAvailable: Bool {
        switch config.server {
        case .main, .classic, .poa, .kovan, .ropsten, .rinkeby, .sokol: return true
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

    var transactionIDLabelTitle: String {
        return NSLocalizedString("transaction.id.label.title", value: "Transaction #", comment: "")
    }

    var to: String {
        guard let to = transaction.operation?.to else {
            return transaction.to
        }
        return to
    }

    var toLabelTitle: String {
        return NSLocalizedString("transaction.to.label.title", value: "To", comment: "")
    }

    var from: String {
        return transaction.from
    }

    var fromLabelTitle: String {
        return NSLocalizedString("transaction.from.label.title", value: "From", comment: "")
    }

    var gasViewModel: GasViewModel {
        let gasUsed = BigInt(transaction.gasUsed) ?? BigInt()
        let gasPrice = BigInt(transaction.gasPrice) ?? BigInt()
        let gasLimit = BigInt(transaction.gas) ?? BigInt()
        let gasFee: BigInt = {
            switch transaction.state {
            case .completed, .error: return gasPrice * gasUsed
            case .pending, .unknown, .failed: return gasPrice * gasLimit
            }
        }()

        return GasViewModel(fee: gasFee, symbol: config.server.symbol, currencyRate: currencyRate, formatter: fullFormatter)
    }

    var gasFee: String {
        let feeAndSymbol = gasViewModel.feeText
        return feeAndSymbol
    }

    var gasFeeLabelTitle: String {
        return NSLocalizedString("transaction.gasFee.label.title", value: "Gas Fee", comment: "")
    }

    var confirmation: String {
        guard let confirmation = chainState.confirmations(fromBlock: transaction.blockNumber) else {
            return "--"
        }
        return String(confirmation)
    }

    var confirmationLabelTitle: String {
        return NSLocalizedString("transaction.confirmation.label.title", value: "Confirmation", comment: "")
    }

    var blockNumber: String {
        return String(transaction.blockNumber)
    }

    var blockNumberLabelTitle: String {
        return NSLocalizedString("transaction.blockNumber.label.title", value: "Block #", comment: "")
    }

    var amountAttributedString: NSAttributedString {
        return transactionViewModel.fullAmountAttributedString
    }

    var shareItem: URL {
        return detailsURL
    }
}
