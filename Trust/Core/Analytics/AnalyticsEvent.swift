// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum AnalyticsEvent {
    case welcomeScreen
    case importWallet(ImportSelectionType)
    case createdWallet

    var event: String {
        switch self {
        case .welcomeScreen:
            return "welcomeScreen"
        case .importWallet:
            return "importWallet"
        case .createdWallet:
            return "createdWallet"
        }
    }

    var params: [String: Any] {
        switch self {
        case .welcomeScreen:
            return [:]
        case .importWallet(let type):
            return ["type": type.title]
        case .createdWallet:
            return [:]
            
        }
    }
}
