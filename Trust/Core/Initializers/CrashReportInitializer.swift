// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Fabric
import Crashlytics

final class CrashReportInitializer: NSObject, Initializer {

    func perform() {
        guard !isDebug else { return }
        Crashlytics.sharedInstance().delegate = self
        var analitics: [Any] = [Crashlytics.self]
        if Analitics.answer.isEnabled {
            analitics.append(Answers.self)
        }
        Fabric.with(analitics)
    }

}

extension CrashReportInitializer: CrashlyticsDelegate {
    func crashlyticsDidDetectReport(forLastExecution report: CLSReport, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(Analitics.crashlytics.isEnabled)
    }
}
