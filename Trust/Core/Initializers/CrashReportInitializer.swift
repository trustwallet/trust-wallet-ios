// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Fabric
import Crashlytics

class CrashReportInitializer: NSObject, Initializer {

    func perform() {
        guard !isDebug else { return }
        Crashlytics.sharedInstance().delegate = self
        Fabric.with([Crashlytics.self, Answers.self])
    }

}

extension CrashReportInitializer: CrashlyticsDelegate {

    func crashlyticsDidDetectReport(forLastExecution report: CLSReport, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(Analitics.crashlytics.isEnabled)
    }
}
