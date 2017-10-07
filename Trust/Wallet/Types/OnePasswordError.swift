// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum OnePasswordError: LocalizedError {
    case wrongFormat

    var errorDescription: String? {
        switch self {
        case .wrongFormat: return "Wrong format"
        }
    }
}
