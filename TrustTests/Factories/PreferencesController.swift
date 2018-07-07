// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust

extension PreferencesController {
    static func make(
        userDefaults: UserDefaults = .test
    ) -> PreferencesController {
        return PreferencesController(
            userDefaults: userDefaults
        )
    }
}
