// Copyright SIX DAY LLC. All rights reserved.

import UIKit

struct AnaliticsViewModel {

    let answer = Analitics.answer

    let branch = Analitics.branch

    let crashlytics = Analitics.crashlytics

    var title: String {
        return NSLocalizedString("settings.analytics.title", value: "Analytics", comment: "")
    }

    var alertTitleEnable: String {
        return String(format: NSLocalizedString("analitics.restart.alert.message", value: "To enable %@ please restart the application", comment: ""), Analitics.answer.name)
    }

    var alertTitleDisable: String {
        return String(format: NSLocalizedString("analitics.restart.alert.message", value: "To disable %@ please restart the application", comment: ""), Analitics.answer.name)
    }

    var alertOK: String {
        return NSLocalizedString("OK", value: "OK", comment: "")
    }
}
