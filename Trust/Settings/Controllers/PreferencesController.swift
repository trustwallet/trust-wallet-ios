// Copyright DApps Platform Inc. All rights reserved.

import Foundation

final class PreferencesController {

    let userDefaults: UserDefaults

    init(
        userDefaults: UserDefaults = .standard
    ) {
        self.userDefaults = userDefaults
    }

    func set(value: Bool, for option: PreferenceOption) {
        userDefaults.set(value, forKey: option.key)
    }

    func set(value: Int, for option: PreferenceOption) {
        userDefaults.set(value, forKey: option.key)
    }

    func set(value: Any, for option: String) {
        userDefaults.setValue(value, forKey: option)
    }

    func get(for option: PreferenceOption) -> Bool {
        return userDefaults.bool(forKey: option.key)
    }

    func get(for option: PreferenceOption) -> Int {
        return userDefaults.integer(forKey: option.key)
    }

    func get(for option: String) -> Any? {
        return userDefaults.value(forKey: option)
    }
}
