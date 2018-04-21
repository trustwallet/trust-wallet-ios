// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum AnalyticsEvent {
    case welcomeScreen
    case importWallet(ImportSelectionType)

    var event: String {
        switch self {
        case .welcomeScreen:
            return "welcomeScreen"
        case .importWallet:
            return "importWallet"
        }
    }

    var params: [String: Any] {
        switch self {
        case .welcomeScreen:
            return [:]
        case .importWallet(let type):
            return ["type": type.title]
        }
    }
}
