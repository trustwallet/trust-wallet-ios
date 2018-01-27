// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockViewModel {
    private let lock = Lock()
    func charCount() -> Int {
        //This step is required for old clients to support 4 digit passcode.
        var count = 0
        if lock.isPasscodeSet() {
            count = lock.currentPasscode()!.count
        } else {
            count = 6
        }
        return count
    }
    func passcodeAttemptLimit() -> Int {
        //If max attempt limit is rached we should give only 1 attempt.
        return lock.incorrectMaxAttemptTimeIsSet() ? 1 : 5
    }
}
