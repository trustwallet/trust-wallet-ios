// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum SettingsError: LocalizedError {
    case failedToSendEmail

    var errorDescription: String? {
        switch self {
        case .failedToSendEmail:
            return NSLocalizedString("settings.error.failedToSendEmail", value: "Failed to send email. Make sure you have Mail app installed.", comment: "")
        }
    }
}
