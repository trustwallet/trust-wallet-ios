// Copyright SIX DAY LLC. All rights reserved.

import Foundation

extension UserDefaults {
    static var test: UserDefaults {
        return UserDefaults(suiteName: NSUUID().uuidString)!
    }
}
