// Copyright SIX DAY LLC. All rights reserved.

import Foundation
@testable import Trust

class FakeJailbrakeChecker: JailbrakeCheckerProtocol {
    let jailbroken: Bool

    init(jailbroken: Bool) {
        self.jailbroken = jailbroken
    }

    func isJailbroken() -> Bool {
        return jailbroken
    }
}
