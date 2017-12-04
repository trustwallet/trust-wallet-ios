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
        return NSLocalizedString("confirmPayment.title", value: "Confirm", comment: "")
    }

    var sendButtonText: String {
        return NSLocalizedString("confirmPayment.send", value: "Send", comment: "")
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

    var addressText: String {
        return transaction.address.address
    }

    var feeText: String {
        let fee = fullFormatter.string(from: totalFee)
        let feeAndSymbol = fee.description + " \(config.server.symbol)"
        let warningFee = BigInt(EthereumUnit.ether.rawValue) / BigInt(20)
        guard totalFee <= warningFee else {
            return feeAndSymbol + " - WARNING. HIGH FEE."
        }
        return feeAndSymbol
    }

    var gasLimiText: String {
        return gasLimit.description
    }
}
