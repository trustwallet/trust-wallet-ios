// Copyright DApps Platform Inc. All rights reserved.

import Foundation
@testable import Trust

class FakeJailbreakChecker: JailbreakChecker {
    let jailbroken: Bool

    init(jailbroken: Bool) {
        self.jailbroken = jailbroken
    }

    func isJailbroken() -> Bool {
        return jailbroken
    }
}
