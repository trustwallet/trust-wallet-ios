// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum AutoLock: Int {
    case disabled
    case oneMinute
    case fiveMinutes
    case oneHour
    case fiveHours

    var name: String {
        switch self {
        case .disabled: return NSLocalizedString("wallets.navigation.title.autolock.disabled", value: "Disabled", comment: "")
        case .oneMinute: return NSLocalizedString("wallets.navigation.title.autolock.one.minute", value: "If away for 1 minute", comment: "")
        case .fiveMinutes: return NSLocalizedString("wallets.navigation.title.autolock.five.minutes", value: "If away for 5 minutes", comment: "")
        case .oneHour: return NSLocalizedString("wallets.navigation.title.autolock.one.hour", value: "If away for 1 hour", comment: "")
        case .fiveHours: return NSLocalizedString("wallets.navigation.title.autolock.five.hour", value: "If away for 5 hours", comment: "")
        }
    }

    var displayName: String {
        return "\(self.name)"
    }
}
