// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum PreferenceOption {
    case showTokensOnLaunch
    case airdropNotifications

    var key: String {
        switch self {
        case .showTokensOnLaunch: return "showTokensOnLaunch"
        case .airdropNotifications: return "airdropNotifications"
        }
    }
}
