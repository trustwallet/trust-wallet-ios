// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum ExchangeTokenError: LocalizedError {
    case failedToGetRates

    var errorDescription: String? {
        switch self {
        case .failedToGetRates:
            return NSLocalizedString("exchange.failedToGetRates", comment: "Failed to get rates")
        }
    }
}
