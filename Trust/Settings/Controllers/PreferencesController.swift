// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class PreferencesController {

    let userDefaults: UserDefaults

    init(
        userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults
    }

    func set(value: Bool, for option: PreferenceOption) {
        userDefaults.set(value, forKey: option.key)
    }

    func get(for option: PreferenceOption) -> Bool {
        return userDefaults.bool(forKey: option.key)
    }
}
