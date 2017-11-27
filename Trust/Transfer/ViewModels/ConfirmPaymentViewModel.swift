// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct ConfirmPaymentViewModel {

    let transaction: UnconfirmedTransaction
    let currentBalance: Double?
    let configuration: TransactionConfiguration
    let config: Config

    init(
        transaction: UnconfirmedTransaction,
        currentBalance: Double?,
        configuration: TransactionConfiguration,
        config: Config = Config()
    ) {
        self.transaction = transaction
        self.currentBalance = currentBalance
        self.configuration = configuration
        self.config = config
    }

    private var totalFee: BigInt {
        return configuration.speed.gasPrice * configuration.speed.gasLimit
    }

    private var gasLimit: BigInt {
        return configuration.speed.gasLimit
    }

    private var fee: String {
        return EthereumConverter.from(value: totalFee, to: .ether, minimumFractionDigits: 6)
    }

    var amount: Double {
        return transaction.amount
    }

    var addressText: String {
        return transaction.address.address
    }

    var feeText: String {
        return fee.description + " \(config.server.symbol)"
    }

    var gasLimiText: String {
        return gasLimit.description
    }
}
