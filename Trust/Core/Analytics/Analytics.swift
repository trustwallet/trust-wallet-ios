// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Firebase

class Analytics {

    static private var sendLogsAreDisabled: Bool {
        let preferences = PreferencesController()
        return preferences.get(for: .sendLogs)
    }

    static func track(_ event: AnalyticsEvent) {
        guard !sendLogsAreDisabled else { return }
        Firebase.Analytics.logEvent(event.event, parameters: event.params)
    }
}
