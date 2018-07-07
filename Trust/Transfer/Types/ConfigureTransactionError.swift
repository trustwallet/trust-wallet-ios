// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import BigInt

enum ConfigureTransactionError: LocalizedError {
    case gasLimitTooHigh
    case gasFeeTooHigh

    var errorDescription: String? {
        switch self {
        case .gasLimitTooHigh:
            return String(
                format: NSLocalizedString(
                    "configureTransaction.error.gasLimitTooHigh",
                    value: "Gas Limit too high. Max available: %d",
                    comment: ""
                ),
                ConfigureTransaction.gasLimitMax
            )
        case .gasFeeTooHigh:
            return String(
                format: NSLocalizedString(
                    "configureTransaction.error.gasFeeHigh",
                    value: "Gas Fee is too high. Max available: %@ %@",
                    comment: ""
                ),
                EtherNumberFormatter.full.string(from: ConfigureTransaction.gasFeeMax),
                Config().server.symbol
            )
        }
    }
}
