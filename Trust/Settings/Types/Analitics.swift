// Copyright DApps Platform Inc. All rights reserved.

import UIKit

enum Analitics: String {
    case crashlytics
    case branch
    case answer

    var title: String {
        switch self {
        case .answer: return R.string.localizable.dailyUsage()
        case .branch: return R.string.localizable.deferredDeepLinking()
        case .crashlytics: return R.string.localizable.crashReports()
        }
    }

    var description: String {
        switch self {
        case .crashlytics:
            return R.string.localizable.settingsAnaliticsCrashlyticsDescription()
        case .branch:
            return R.string.localizable.settingsAnaliticsBranchDescription()
        case .answer:
            return R.string.localizable.settingsAnaliticsAnswerDescription()
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
