// Copyright SIX DAY LLC. All rights reserved.

import UIKit
@testable import Trust

class FakeLockProtocol: LockInterface {
    var passcodeSet = true
    func isPasscodeSet() -> Bool {
        return passcodeSet
    }
}
