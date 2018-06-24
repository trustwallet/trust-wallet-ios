// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum Analitics: String {
    case crashlytics
    case branch
    case answer

    var isEnabled: Bool {
        let preferencesController = PreferencesController()
        guard let object = preferencesController.get(for: self.rawValue), let number = object as? NSNumber else {
            preferencesController.set(value: NSNumber(booleanLiteral: true), for: self.rawValue)
            return true
        }
        return number.boolValue
    }

    func update(with state: Bool) {
        let preferencesController = PreferencesController()
        preferencesController.set(value: NSNumber(booleanLiteral: state), for: self.rawValue)
    }
}
