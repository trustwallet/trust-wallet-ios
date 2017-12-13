// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct ConfirmPaymentViewModel {

    let transaction: UnconfirmedTransaction
    let currentBalance: BalanceProtocol?
    let configuration: TransactionConfiguration
    let config: Config
    private let fullFormatter = EtherNumberFormatter.full

    init(
        transaction: UnconfirmedTransaction,
        currentBalance: BalanceProtocol?,
        configuration: TransactionConfiguration,
        config: Config = Config()
    ) {
        self.transaction = transaction
        self.currentBalance = currentBalance
        self.configuration = configuration
        self.config = config
    }

    var title: String {
        return NSLocalizedString("confirmPayment.confirm.button.title", value: "Confirm", comment: "")
    }

    var sendButtonText: String {
        return NSLocalizedString("Send", value: "Send", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }

    private var totalFee: BigInt {
        return configuration.speed.gasPrice * configuration.speed.gasLimit
    }

    private var gasLimit: BigInt {
        return configuration.speed.gasLimit
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
        return transaction.address.address
    }

    var gasPriceTitle: String {
        return NSLocalizedString("confirmPayment.gasPrice.label.title", value: "Gas Price", comment: "")
    }

    var gasPriceText: String {
        let unit = UnitConfiguration.gasPriceUnit
        let amount = fullFormatter.string(from: configuration.speed.gasPrice, units: UnitConfiguration.gasPriceUnit)
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
        let fee = fullFormatter.string(from: totalFee)
        let feeAndSymbol = String(
            format: "%@ %@",
            fee.description,
            config.server.symbol
        )

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

    var amountAttributedString: NSAttributedString {
        switch transaction.transferType {
        case .token(let token):
            return amountAttributedText(
                string: fullFormatter.string(from: transaction.value, decimals: token.decimals)
            )
        case .ether:
            return amountAttributedText(
                string: fullFormatter.string(from: transaction.value)
            )
        case .exchange(let from, let to):
            let fromAttributedString: NSAttributedString = {
                let amount = NSAttributedString(
                    string: fullFormatter.string(from: from.amount),
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 24),
                        .foregroundColor: Colors.red,
                    ]
                )

                let currency = NSAttributedString(
                    string: " " + from.token.symbol,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                    ]
                )
                return amount + currency
            }()

            let toAttributedString: NSAttributedString = {
                let amount = NSAttributedString(
                    string: fullFormatter.string(from: to.amount),
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 24),
                        .foregroundColor: Colors.green,
                    ]
                )

                let currency = NSAttributedString(
                    string: " " + to.token.symbol,
                    attributes: [
                        .font: UIFont.systemFont(ofSize: 16),
                    ]
                )
                return amount + currency
            }()

            let amount = NSAttributedString(
                string: String(" for "),
                attributes: [
                    .font: UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.light),
                ]
            )
            return fromAttributedString + amount + toAttributedString
        }
    }

    private func amountAttributedText(string: String) -> NSAttributedString {
        let amount = NSAttributedString(
            string: string,
            attributes: [
                .font: UIFont.systemFont(ofSize: 28),
                .foregroundColor: amountTextColor,
            ]
        )

        let currency = NSAttributedString(
            string: " \(transaction.transferType.symbol(server: config.server))",
            attributes: [
                .font: UIFont.systemFont(ofSize: 20),
            ]
        )
        return amount + currency
    }
}
