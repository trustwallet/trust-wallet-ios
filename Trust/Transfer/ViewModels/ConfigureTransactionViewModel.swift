// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct ConfigureTransactionViewModel {

    let config: Config
    let transferType: TransferType

    init(
        config: Config,
        transferType: TransferType
    ) {
        self.config = config
        self.transferType = transferType
    }

    var title: String {
        return NSLocalizedString("Advanced", value: "Advanced", comment: "")
    }

    var gasPriceFooterText: String {
        return String(
            format: NSLocalizedString(
                "configureTransaction.gasPrice.label.description",
                value: "With a higher gas price, your transaction fee will be more expensive, but the %@ network will process your transaction faster.",
                comment: ""
            ),
            config.server.name
        )
    }

    var gasLimitFooterText: String {
        return String(
            format: NSLocalizedString(
                "configureTransaction.gasLimit.label.description",
                value: "The gas limit prevents smart contracts from consuming all your %@. We will try to calculate the gas limit automatically for you, but some smart contracts may require a custom gas limit.",
                comment: ""
            ),
            config.server.name
        )
    }
}
