// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum AnalyticsEvent {
    case welcomeScreen
    case importWallet(ImportSelectionType)
    case createdWallet
    case completedTransaction
    case failedTransaction
    case signedMessage
    case failedSignedMessage
    case backedUpWallet

    var event: String {
        switch self {
        case .welcomeScreen:
            return "welcomeScreen"
        case .importWallet:
            return "importWallet"
        case .createdWallet:
            return "createdWallet"
        case .completedTransaction:
            return "completedTransaction"
        case .failedTransaction:
            return "failedTransaction"
        case .signedMessage:
            return "signedMessage"
        case .failedSignedMessage:
            return "failedSignedMessage"
        case .backedUpWallet:
            return "backedUpWallet"
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
        case .completedTransaction:
            return [:]
        case .failedTransaction:
            return [:]
        case .signedMessage:
            return [:]
        case .failedSignedMessage:
            return [:]
        case .backedUpWallet:
            return [:]
            
        }
    }
}
