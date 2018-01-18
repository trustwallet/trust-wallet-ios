// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum ExchangeTokenError: LocalizedError {
    case failedToGetRates
    case wrongInput

    var errorDescription: String? {
        switch self {
        case .failedToGetRates:
            return NSLocalizedString("exchange.error.failedToGetRates", comment: "Failed to get rates")
        case .wrongInput:
            return NSLocalizedString("exchange.error.wrongInput", comment: "Wrong input")
        }
    }
}
