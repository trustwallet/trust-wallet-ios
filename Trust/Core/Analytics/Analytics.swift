// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Firebase

class Analytics {

    static func track(_ event: AnalyticsEvent) {
        Firebase.Analytics.logEvent(event.event, parameters: event.params)
    }
}
