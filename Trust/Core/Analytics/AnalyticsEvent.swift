// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum AnalyticsEvent {
    case welcomeScreen

    var event: String {
        switch self {
        case .welcomeScreen:
            return "welcomeScreen"
        }
    }

    var params: [String: AnyObject] {
        switch self {
        case .welcomeScreen:
            return [:]
        }
    }
}
