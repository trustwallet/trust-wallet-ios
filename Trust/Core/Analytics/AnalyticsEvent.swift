// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum AnalyticsEvent {
    case welcomeScreen
    case importWallet(ImportSelectionType)
    case createdWallet
    case completedTransaction(TransactionType)
    case failedTransaction(TransactionType)
    case signedMessage(MessageType)
    case failedSignedMessage

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
        case .completedTransaction(let type):
            return ["type": type.title]
        case .failedTransaction(let type):
            return ["type": type.title]
        case .signedMessage(let type):
            return ["type": type.title]
        case .failedSignedMessage:
            return [:]
            
        }
    }
}
