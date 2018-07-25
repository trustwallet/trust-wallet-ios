// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt

struct ConfirmPaymentDetailsViewModel {

    let transaction: PreviewTransaction
    let session: WalletSession
    let config: Config
    let server: RPCServer
    private let fullFormatter = EtherNumberFormatter.full
    private let balanceFormatter = EtherNumberFormatter.balance
    private var monetaryAmountViewModel: MonetaryAmountViewModel {
        return MonetaryAmountViewModel(
            amount: amount,
            contract: transaction.transfer.type.address,
            session: session
        )
    }
    init(
        transaction: PreviewTransaction,
        config: Config = Config(),
        session: WalletSession,
        server: RPCServer
    ) {
        self.transaction = transaction
        self.config = config
        self.session = session
        self.server = server
    }

    private var gasViewModel: GasViewModel {
        return GasViewModel(fee: totalFee, server: server, store: session.tokensStorage, formatter: fullFormatter)
    }

    private var totalViewModel: GasViewModel {

        var value: BigInt = totalFee

        if case TransferType.ether(_) = transaction.transfer.type {
            value += transaction.value
        }

        return GasViewModel(fee: value, server: server, store: session.tokensStorage, formatter: fullFormatter)
    }

    private var totalFee: BigInt {
        return transaction.gasPrice * transaction.gasLimit
    }

    private var gasLimit: BigInt {
        return transaction.gasLimit
    }

    var paymentFromTitle: String {
        return NSLocalizedString("transaction.sender.label.title", value: "Sender", comment: "")
    }

    var requesterTitle: String {
        switch transaction.transfer.type {
        case .dapp:
            return NSLocalizedString("confirmPayment.dapp.label.title", value: "DApp", comment: "")
        case .ether, .token:
            return NSLocalizedString("confirmPayment.to.label.title", value: "To", comment: "")
        }
    }

    var requesterText: String {
        switch transaction.transfer.type {
        case .dapp(_, let request):
            return request.url?.absoluteString ?? ""
        case .ether, .token:
            return transaction.address?.description ?? ""
        }
    }

    var amountTitle: String {
        return NSLocalizedString("confirmPayment.amount.label.title", value: "Amount", comment: "")
    }

    var amountText: String {
        return String(
            format: "%@ %@",
            amountString,
            monetaryAmountString ?? ""
        )
    }

    var estimatedFeeTitle: String {
        return R.string.localizable.networkFee()
    }

    var estimatedFeeText: String {
        let unit = UnitConfiguration.gasPriceUnit
        let amount = fullFormatter.string(from: transaction.gasPrice, units: UnitConfiguration.gasPriceUnit)
        return  String(
            format: "%@ %@ (%@)",
            amount,
            unit.name,
            gasViewModel.monetaryFee ?? ""
        )
    }

    var amountTextColor: UIColor {
        return Colors.red
    }

    var totalTitle: String {
        return NSLocalizedString("confirmPayment.maxTotal.label.title", value: "Max Total", comment: "")
    }

    var totalText: String {
        let feeDouble = gasViewModel.feeCurrency ?? 0
        let amountDouble = monetaryAmountViewModel.amountCurrency ?? 0

        guard let totalAmount = FeeCalculator.format(fee: feeDouble + amountDouble) else {
            return "--"
        }
        return totalAmount
    }

    var amount: String {
        switch transaction.transfer.type {
        case .token(let token):
            return balanceFormatter.string(from: transaction.value, decimals: token.decimals)
        case .ether(let token, _), .dapp(let token, _):
            return balanceFormatter.string(from: transaction.value, decimals: token.decimals)
        }
    }

    var transactionHeaderViewModel: TransactionHeaderViewViewModel {
        return TransactionHeaderViewViewModel(
            amountString: amountString,
            amountTextColor: amountTextColor,
            monetaryAmountString: monetaryAmountString,
            statusImage: statusImage
        )
    }

    var amountString: String {
        return amountWithSign(for: amount) + " \(transaction.transfer.type.symbol(server: server))"
    }

    var monetaryAmountString: String? {
        return monetaryAmountViewModel.amountText
    }

    var statusImage: UIImage? {
        return R.image.transaction_sent()
    }

    private func amountWithSign(for amount: String) -> String {
        guard amount != "0" else { return amount }
        return "-\(amount)"
    }
}
