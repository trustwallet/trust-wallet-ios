// Copyright SIX DAY LLC. All rights reserved.

import UIKit
@testable import Trust

class FakeLockProtocol: LockInterface {
    func isPasscodeSet() -> Bool {
        return true
    }
}
