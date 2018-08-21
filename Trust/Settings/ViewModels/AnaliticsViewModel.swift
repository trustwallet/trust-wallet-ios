// Copyright DApps Platform Inc. All rights reserved.

import UIKit

struct AnaliticsViewModel {

    let answer = Analitics.answer

    let branch = Analitics.branch

    var title: String {
        return NSLocalizedString("settings.privacy.title", value: "Privacy", comment: "")
    }
}
