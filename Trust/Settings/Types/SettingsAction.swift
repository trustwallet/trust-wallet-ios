// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum SettingsAction {
    case wallets
    case RPCServer
    case currency
    case DAppsBrowser
    case pushNotifications(enabled: Bool)
}
