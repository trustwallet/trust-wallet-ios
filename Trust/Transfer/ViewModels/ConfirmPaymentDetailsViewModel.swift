// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct ConfirmPaymentDetailsViewModel {

    let transaction: PreviewTransaction
    let currentBalance: BalanceProtocol?
    let currencyRate: CurrencyRate?
    let config: Config
    private let fullFormatter = EtherNumberFormatter.full

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
        return GasViewModel(fee: totalFee, symbol: config.server.symbol, currencyRate: currencyRate, formatter: fullFormatter)
    }

    private var totalViewModel: GasViewModel {

        var value: BigInt = totalFee

        if case TransferType.ether(_) = transaction.transferType {
            value += transaction.value
        }

        return GasViewModel(fee: value, symbol: config.server.symbol, currencyRate: currencyRate, formatter: fullFormatter)
    }

    private var totalFee: BigInt {
        return transaction.gasPrice * transaction.gasLimit
    }

    private var gasLimit: BigInt {
        return transaction.gasLimit
    }

    var amount: String {
        return fullFormatter.string(from: transaction.value)
    }

    var paymentFromTitle: String {
        return NSLocalizedString("confirmPayment.from.label.title", value: "From", comment: "")
    }

    var paymentToTitle: String {
        return NSLocalizedString("confirmPayment.to.label.title", value: "To", comment: "")
    }
    var paymentToText: String {
        return transaction.address?.description ?? "--"
    }

    var gasPriceTitle: String {
        return NSLocalizedString("confirmPayment.gasPrice.label.title", value: "Gas Price", comment: "")
    }

    var gasPriceText: String {
        let unit = UnitConfiguration.gasPriceUnit
        let amount = fullFormatter.string(from: transaction.gasPrice, units: UnitConfiguration.gasPriceUnit)
        return  String(
            format: "%@ %@",
            amount,
            unit.name
        )
    }

    var feeTitle: String {
        return NSLocalizedString("confirmPayment.gasFee.label.title", value: "Network Fee", comment: "")
    }

    var feeText: String {
        let feeAndSymbol = gasViewModel.feeText
        let warningFee = BigInt(EthereumUnit.ether.rawValue) / BigInt(20)
        guard totalFee <= warningFee else {
            return feeAndSymbol + " - WARNING. HIGH FEE."
        }
        return feeAndSymbol
    }

    var gasLimitTitle: String {
        return NSLocalizedString("confirmPayment.gasLimit.label.title", value: "Gas Limit", comment: "")
    }

    var gasLimitText: String {
        return gasLimit.description
    }

    var amountTextColor: UIColor {
        return Colors.red
    }

    var totalTitle: String {
        return NSLocalizedString("confirmPayment.maxTotal.label.title", value: "Max Total", comment: "")
    }

    var totalText: String {
        return totalViewModel.feeText
    }

    var amountString: String {
        let amount: String = {
            switch transaction.transferType {
            case .token(let token):
                return fullFormatter.string(from: transaction.value, decimals: token.decimals)
            case .ether, .dapp:
                return fullFormatter.string(from: transaction.value)
            }
        }()
        return amountWithSign(for: amount) + " \(transaction.transferType.symbol(server: config.server))"
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 20, weight: .medium)
    }

    private func amountWithSign(for amount: String) -> String {
        guard amount != "0" else { return amount }
        return "-\(amount)"
    }
}
