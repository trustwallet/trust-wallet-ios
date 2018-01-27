// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockEnterPasscodeViewController: LockPasscodeViewController {
    private lazy var lockEnterPasscodeViewModel: LockEnterPasscodeViewModel? = {
        return self.model as? LockEnterPasscodeViewModel
    }()
    override func viewDidLoad() {
        self.lockView.lockTitle.text = lockEnterPasscodeViewModel?.initialLabelText
    }
    override func enteredPasscode(_ passcode: String) {
        super.enteredPasscode(passcode)
        if lock.isPasscodeValid(passcode: passcode) {
            lock.resetPasscodeAttemptHistory()
            finish(withResult: true, animated: true)
        } else {
            lockView.lockTitle.text = lockEnterPasscodeViewModel?.incorrectLabelText
            lockView.shake()
            if self.lock.numberOfAttempts() == model.passcodeAttemptLimit {
                exceededLimit()
                return
            }
            self.lock.recordIncorrectPasscodeAttempt()
        }
    }
    private func exceededLimit() {
        print("Limit Reached")
    }
}
