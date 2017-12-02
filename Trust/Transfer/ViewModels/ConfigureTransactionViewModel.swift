// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ConfigureTransactionViewModel {

    let config: Config

    init(
        config: Config
    ) {
        self.config = config
    }

    var title: String {
        return "Advanced"
    }

    var gasPriceFooterText: String {
        return String(
            format: NSLocalizedString(
                "configureTransaction.gasPriceDescription",
                value: "The higher the gas price, the more expesnive your transaction fee will be, but the quicker your tranasction will be processed by the %@ network.",
                comment: ""
            ),
            config.server.name
        )
    }

    var gasLimitFooterText: String {
        return String(
            format: NSLocalizedString(
                "configureTransaction.gasLimitDescription",
                value: "The gas limit prevents smart contracts from consuming all your %@. We will try to calculate the gas limit automatically for you, but some smart contracts may require a custom gas limit.",
                comment: ""
            ),
            config.server.name
        )
    }
}
