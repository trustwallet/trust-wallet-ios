// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum AnalyticsEvent {
    // Acquisition events
    case welcomeScreen
    // Activation events - creating or importing a wallet
    case importedWallet(ImportSelectionType)
    case failedImportWallet(ImportSelectionType)
    case createdWallet
    // Retention events - signing a message or sending a transaction
    case completedTransactionFromBrowser
    case failedTransactionFromBrowser
    case signedMessageFromBrowser
    case failedSignedMessageFromBrowser
    case sentTransactionFromWallet
    case failedTransactionFromWallet
    // Other  events
    case backedUpWallet

    var event: String {
        switch self {
        case .welcomeScreen:
            return "welcomeScreen"
        case .importedWallet:
            return "importedWallet"
        case .failedImportWallet:
            return "failedImportWallet"
        case .createdWallet:
            return "createdWallet"
        case .completedTransactionFromBrowser:
            return "completedTransactionFromBrowser"
        case .failedTransactionFromBrowser:
            return "failedTransactionFromBrowser"
        case .signedMessageFromBrowser:
            return "signedMessageFromBrowser"
        case .failedSignedMessageFromBrowser:
            return "failedSignedMessageFromBrowser"
        case .sentTransactionFromWallet:
            return "sentTransactionFromWallet"
        case .failedTransactionFromWallet:
            return "failedTransactionFromWallet"
        case .backedUpWallet:
            return "backedUpWallet"
        }
    }

    var params: [String: Any] {
        switch self {
        case .welcomeScreen:
            return [:]
        case .importedWallet(let type):
            return ["type": type.title]
        case .failedImportWallet(let type):
            return ["type": type.title]
        case .createdWallet:
            return [:]
        case .completedTransactionFromBrowser:
            return [:]
        case .failedTransactionFromBrowser:
            return [:]
        case .signedMessageFromBrowser:
            return [:]
        case .failedSignedMessageFromBrowser:
            return [:]
        case .sentTransactionFromWallet:
            return [:]
        case .failedTransactionFromWallet:
            return [:]
        case .backedUpWallet:
            return [:]
        }
    }
}
