// Copyright SIX DAY LLC. All rights reserved.

import UIKit

struct AnaliticsViewModel {

    let answer = Analitics.answer

    let branch = Analitics.branch

    let crashlytics = Analitics.crashlytics

    var title: String {
        return NSLocalizedString("settings.analytics.title", value: "Analytics", comment: "")
    }
}
