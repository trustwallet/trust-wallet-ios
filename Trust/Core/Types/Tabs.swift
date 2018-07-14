// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

enum WalletAction {
    case none
    case addToken(EthereumAddress)
}

enum Tabs {
    case browser(openURL: URL?)
    case wallet(WalletAction)
    case settings

    var index: Int {
        switch self {
        case .browser: return 0
        case .wallet: return 1
        case .settings: return 2
        }
    }
}

extension Tabs: Equatable {
    static func == (lhs: Tabs, rhs: Tabs) -> Bool {
        switch (lhs, rhs) {
        case (let .browser(lhs), let .browser(rhs)):
            return lhs == rhs
        case (.wallet, .wallet),
             (.settings, .settings):
            return true
        case (_, .browser),
             (_, .wallet),
             (_, .settings):
            return false
        }
    }
}
