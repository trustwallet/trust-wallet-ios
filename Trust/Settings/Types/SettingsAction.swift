// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum SettingsAction {
    case wallets
    case RPCServer
    case donate(address: Address)
    case pushNotifications(enabled: Bool)
}
