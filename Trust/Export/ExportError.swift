// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum ExportError: LocalizedError {
    case missingPassword

    var errorDescription: String? {
        switch self {
        case .missingPassword:
            return "Missing password"
        }
    }
}
