// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt

struct ConfirmPaymentDetailsViewModel {

    let transaction: PreviewTransaction
    let currentBalance: BalanceProtocol?
    let currencyRate: CurrencyRate?
    let config: Config
    private let fullFormatter = EtherNumberFormatter.full
    private let balanceFormatter = EtherNumberFormatter.balance
    private var monetaryAmountViewModel: MonetaryAmountViewModel {
        return MonetaryAmountViewModel(
            amount: amount,
            address: transaction.transferType.contract(),
            currencyRate: currencyRate
        )
    }
    init(
        transaction: PreviewTransaction,
        config: Config = Config(),
        currentBalance: BalanceProtocol?,
        currencyRate: CurrencyRate?
    ) {
        self.transaction = transaction
        self.currentBalance = currentBalance
        self.config = config
        self.currencyRate = currencyRate
    }

    private var gasViewModel: GasViewModel {
        return GasViewModel(fee: totalFee, server: config.server, currencyRate: currencyRate, formatter: fullFormatter)
    }

    private var totalViewModel: GasViewModel {

        var value: BigInt = totalFee

        if case TransferType.ether(_) = transaction.transferType {
            value += transaction.value
        }

        return GasViewModel(fee: value, server: config.server, currencyRate: currencyRate, formatter: fullFormatter)
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
        switch transaction.transferType {
        case .dapp:
            return NSLocalizedString("confirmPayment.dapp.label.title", value: "DApp", comment: "")
        case .ether, .token, .nft:
            return NSLocalizedString("confirmPayment.to.label.title", value: "To", comment: "")
        }
    }

    var requesterText: String {
        switch transaction.transferType {
        case .dapp(let request):
            return request.url?.absoluteString ?? ""
        case .ether, .token, .nft:
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
        return NSLocalizedString("Network Fee", value: "Network Fee", comment: "")
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

        let rate = CurrencyRate(rates: [])
        guard let totalAmount = rate.format(fee: feeDouble + amountDouble) else {
            return "--"
        }
        return totalAmount
    }

    var amount: String {
        switch transaction.transferType {
        case .token(let token):
            return balanceFormatter.string(from: transaction.value, decimals: token.decimals)
        case .ether, .dapp, .nft:
            return balanceFormatter.string(from: transaction.value)
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
        return amountWithSign(for: amount) + " \(transaction.transferType.symbol(server: config.server))"
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
