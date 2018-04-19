// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import UIKit
import TrustCore

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
        if transaction.state == .pending {
            return NSLocalizedString("Pending", value: "Pending", comment: "")
        }
        if transactionViewModel.direction == .incoming {
            return NSLocalizedString("Incoming", value: "Incoming", comment: "")
        }
        return NSLocalizedString("Outgoing", value: "Outgoing", comment: "")
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
        return detailsURL != nil
    }

    var shareAvailable: Bool {
        return detailsAvailable
    }

    var detailsURL: URL? {
        return ConfigExplorer(server: config.server).transactionURL(for: transaction.id)
    }

    var transactionID: String {
        return transaction.id
    }

    var transactionIDLabelTitle: String {
        return NSLocalizedString("transaction.id.label.title", value: "Transaction #", comment: "")
    }

    var address: String {
        if transaction.toAddress == nil {
            return Address.zero.description
        }
        if transactionViewModel.direction == .incoming {
            return transaction.from
        } else {
            guard let to = transaction.operation?.to else {
                return transaction.to
            }
            return to
        }
    }

    var addressTitle: String {
        if transactionViewModel.direction == .incoming {
            return NSLocalizedString("transaction.sender.label.title", value: "Sender", comment: "")
        } else {
            return NSLocalizedString("transaction.recipient.label.title", value: "Recipient", comment: "")
        }
    }

    var nonce: String {
        return String(transaction.nonce)
    }

    var nonceTitle: String {
        return NSLocalizedString("Nonce", value: "Nonce", comment: "")
    }

    var gasViewModel: GasViewModel {
        let gasUsed = BigInt(transaction.gasUsed) ?? BigInt()
        let gasPrice = BigInt(transaction.gasPrice) ?? BigInt()
        let gasLimit = BigInt(transaction.gas) ?? BigInt()
        let gasFee: BigInt = {
            switch transaction.state {
            case .completed, .error: return gasPrice * gasUsed
            case .pending, .unknown, .failed, .deleted: return gasPrice * gasLimit
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

    var amountString: String {
        return transactionViewModel.amountText
    }

    var amountTextColor: UIColor {
        return transactionViewModel.amountTextColor
    }

    var amountFont: UIFont {
        return AppStyle.largeAmount.font
    }

    var shareItem: URL? {
        return detailsURL
    }
}
