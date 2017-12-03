// Copyright SIX DAY LLC. All rights reserved.

import Foundation

class JailbrakeChecker: JailbrakeCheckerProtocol {
    func isJailbroken() -> Bool {
        if TARGET_IPHONE_SIMULATOR == 1 {
            return false
        }

        return FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
            || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
            || FileManager.default.fileExists(atPath: "/bin/bash")
            || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
            || FileManager.default.fileExists(atPath: "/etc/apt")
            || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
    }
}
