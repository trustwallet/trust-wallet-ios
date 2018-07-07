// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum SettingsAction {
    case RPCServer(server: RPCServer)
    case currency
    case pushNotifications(NotificationChanged)
    case clearBrowserCache
    case openURL(URL)
}
