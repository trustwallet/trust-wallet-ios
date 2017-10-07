// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum SplashError: LocalizedError {
    case numberOfTries

    var errorDescription: String? {
        switch self {
        case .numberOfTries: return "You have exceeded the max number of tries."
        }
    }
}
