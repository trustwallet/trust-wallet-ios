// Copyright SIX DAY LLC. All rights reserved.

import Foundation

extension Bundle {
    var versionNumber: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}

func isDebug() -> Bool {
    #if DEBUG
        return true
    #else
        return false
    #endif
}
