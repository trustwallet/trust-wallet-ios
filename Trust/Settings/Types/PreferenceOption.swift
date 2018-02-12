// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum PreferenceOption {
    case showTokensOnLaunch

    var key: String {
        switch self {
        case .showTokensOnLaunch: return "showTokensOnLaunch"
        }
    }
}
