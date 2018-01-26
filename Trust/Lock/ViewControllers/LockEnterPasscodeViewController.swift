// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockEnterPasscodeViewController: LockPasscodeViewController {
    private let standardDefaults = UserDefaults.standard
    private let passcodeAttempts = "passcodeAttempts"
    private lazy var lockEnterPasscodeViewModel: LockEnterPasscodeViewModel? = {
        return self.model as? LockEnterPasscodeViewModel
    }()
    override func viewDidLoad() {
        self.lockView.lockTitle.text = lockEnterPasscodeViewModel?.initialLabelText
    }
    override func enteredPasscode(_ passcode: String) {
        super.enteredPasscode(passcode)
        //touchLock.isPasscodeValid(passcode)
        if true {
            self.resetPasscodeAttemptHistory()
            finish(withResult: true, animated: true)
        } else {
            lockView.shake()
            lockView.lockTitle.text = lockEnterPasscodeViewModel?.incorrectLabelText
            self.clearPasscode()
            self.recordIncorrectPasscodeAttempt()
        }
    }
    private func resetPasscodeAttemptHistory() {
        standardDefaults.removeObject(forKey: passcodeAttempts)
    }
    private func recordIncorrectPasscodeAttempt() {
        var numberOfAttemptsSoFar = standardDefaults.integer(forKey: passcodeAttempts)
        numberOfAttemptsSoFar += 1
        standardDefaults.set(passcodeAttempts, forKey: passcodeAttempts)
        if numberOfAttemptsSoFar >= model.passcodeAttemptLimit {
            exceededLimit()
        }
    }
    private func exceededLimit() {
        print("Limit Reached")
    }
}
