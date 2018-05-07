// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum PreferenceOption {
    case airdropNotifications
    case browserSearchEngine
    case sendLogs

    var key: String {
        switch self {
        case .airdropNotifications: return "airdropNotifications"
        case .browserSearchEngine: return "browserSearchEngine"
        case .sendLogs: return "sendLogs"
        }
    }
}
