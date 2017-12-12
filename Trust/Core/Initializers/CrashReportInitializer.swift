// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Fabric
import Crashlytics

struct CrashReportInitializer: Initializer {

    func perform() {
        Fabric.with([Crashlytics.self, Answers.self])
    }
}
