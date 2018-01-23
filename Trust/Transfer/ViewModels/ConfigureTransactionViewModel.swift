// Copyright SIX DAY LLC. All rights reserved.

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
                value: "The higher the gas price, the more expensive your transaction fee will be, but the quicker your tranasction will be processed by the %@ network.",
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

    var isDataInputHidden: Bool {
        switch transferType {
        case .ether: return false
        case .token: return true
        }
    }
}
