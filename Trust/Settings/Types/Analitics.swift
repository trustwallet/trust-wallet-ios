// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum Analitics: String {
    case crashlytics
    case branch
    case answer

    var isEnabled: Bool {
        let userDefaults: UserDefaults = .standard
        guard let object = userDefaults.value(forKey: self.rawValue), let number = object as? NSNumber else {
            userDefaults.setValue(NSNumber(booleanLiteral: true), forKey: self.rawValue)
            return true
        }
        return number.boolValue
    }

    func update(with state: Bool) {
        let userDefaults: UserDefaults = .standard
        userDefaults.setValue(NSNumber(booleanLiteral: state), forKey: self.rawValue)
    }
}
