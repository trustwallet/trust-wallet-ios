// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockEnterPasscodeViewController: LockPasscodeViewController {
    private lazy var lockEnterPasscodeViewModel: LockEnterPasscodeViewModel? = {
        return self.model as? LockEnterPasscodeViewModel
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.lockView.lockTitle.text = lockEnterPasscodeViewModel?.initialLabelText
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //If max attempt limit is reached we should valdiate if one minute gone.
        if lock.incorrectMaxAttemptTimeIsSet() {
            self.lockView.lockTitle.text = lockEnterPasscodeViewModel?.tryAfterOneMinute
            maxAttemptTimerValidation()
        }
    }
    override func enteredPasscode(_ passcode: String) {
        super.enteredPasscode(passcode)
        if lock.isPasscodeValid(passcode: passcode) {
            lock.resetPasscodeAttemptHistory()
            lock.removeIncorrectMaxAttemptTime()
            self.lockView.lockTitle.text = lockEnterPasscodeViewModel?.initialLabelText
            finish(withResult: true, animated: true)
        } else {
            let numberOfAttempts = self.lock.numberOfAttempts()
            let passcodeAttemptLimit = model.passcodeAttemptLimit()
            let text = String(format: NSLocalizedString("lock.enter.passcode.view.model.incorrect.passcode", value: "Incorrect passcode. You have %d attempts.", comment: ""), passcodeAttemptLimit - numberOfAttempts)
            lockView.lockTitle.text = text
            lockView.shake()
            if numberOfAttempts >= passcodeAttemptLimit {
                exceededLimit()
                return
            }
            self.lock.recordIncorrectPasscodeAttempt()
        }
    }
    private func exceededLimit() {
        self.lockView.lockTitle.text = lockEnterPasscodeViewModel?.tryAfterOneMinute
        lock.recordIncorrectMaxAttemptTime()
        self.hideKeyboard()
    }
    private func maxAttemptTimerValidation() {
        let now = Date()
        let maxAttemptTimer = lock.recordedMaxAttemptTime()
        let interval = now.timeIntervalSince(maxAttemptTimer)
        //if interval is greater or equal 60 seconds we give 1 attempt.
        if interval >= 60 {
            self.lockView.lockTitle.text = lockEnterPasscodeViewModel?.initialLabelText
            self.showKeyboard()
        }
    }
}
