// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum Tabs {
    case browser(openURL: URL?)
    case transactions
    case tokens
    case settings

    var index: Int {
        switch self {
        case .browser: return 0
        case .transactions: return 1
        case .tokens: return 2
        case .settings: return 3
        }
    }
}

extension Tabs: Equatable {
    static func == (lhs: Tabs, rhs: Tabs) -> Bool {
        switch (lhs, rhs) {
        case (let .browser(lhs), let .browser(rhs)):
            return lhs == rhs
        case (.transactions, .transactions),
             (.tokens, .tokens),
             (.settings, .settings):
            return true
        case (_, .browser),
             (_, .transactions),
             (_, .tokens),
             (_, .settings):
            return false
        }
    }
}
