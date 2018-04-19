// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum SettingsAction {
    case RPCServer(server: RPCServer)
    case currency
    case pushNotifications(NotificationChanged)
    case openURL(URL)
}
