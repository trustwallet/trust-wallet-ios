// Copyright DApps Platform Inc. All rights reserved.

import Foundation

extension UserDefaults {
    static var test: UserDefaults {
        return UserDefaults(suiteName: NSUUID().uuidString)!
    }
}
