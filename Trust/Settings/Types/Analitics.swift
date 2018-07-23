// Copyright DApps Platform Inc. All rights reserved.

import UIKit

enum Analitics: String {
    case crashlytics
    case branch
    case answer

    var title: String {
        switch self {
        case .answer: return "Daily usage"
        case .branch: return "Deffered deep linking"
        case .crashlytics: return "Crash reports"
        }
    }

    var description: String {
        switch self {
        case .crashlytics:
            return NSLocalizedString("settings.analitics.crashlytics.description", value: "Help Trust developers to improve its product and service by automatically sending crash reports.", comment: "")
        case .branch:
            return NSLocalizedString("settings.analitics.branch.description", value: "Help Trust improve user engagement by sharing deep links redirects.", comment: "")
        case .answer:
            return NSLocalizedString("settings.analitics.answer.description", value: "Help Trust improve user experience by sharing app daily diagnostic.", comment: "")
        }
    }

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
