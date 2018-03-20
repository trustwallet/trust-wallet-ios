// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum PreferenceOption {
    case airdropNotifications

    var key: String {
        switch self {
        case .airdropNotifications: return "airdropNotifications"
        }
    }
}
