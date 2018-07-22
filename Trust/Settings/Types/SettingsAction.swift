// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum SettingsAction {
    case currency
    case pushNotifications(NotificationChanged)
    case clearBrowserCache
    case clearTransactions
    case clearTokens
    case openURL(URL)
    case wallets
}
