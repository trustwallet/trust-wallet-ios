// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum PreferenceOption {
    case airdropNotifications
    case browserSearchEngine
    case testNetworks

    var key: String {
        switch self {
        case .airdropNotifications: return "airdropNotifications"
        case .browserSearchEngine: return "browserSearchEngine"
        case .testNetworks: return "browserSearchEngine"
        }
    }
}
