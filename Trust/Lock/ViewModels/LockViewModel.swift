// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockViewModel {
    private let lock = Lock()
    lazy var charCount: Int = {
        //This step is required for old clients to support 4 digit passcode.
        var count = 0
        if lock.isPasscodeSet() {
            count = lock.currentPasscode()!.count
        } else {
            count = 6
        }
        return count
    }()
    lazy var passcodeAttemptLimit: Int = {
        return 5
    }()
}
