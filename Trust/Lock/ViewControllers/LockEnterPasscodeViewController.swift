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
    override func enteredPasscode(_ passcode: String) {
        super.enteredPasscode(passcode)
        if lock.isPasscodeValid(passcode: passcode) {
            lock.resetPasscodeAttemptHistory()
            self.lockView.lockTitle.text = lockEnterPasscodeViewModel?.initialLabelText
            finish(withResult: true, animated: true)
        } else {
            let numberOfAttempts = self.lock.numberOfAttempts()
            let passcodeAttemptLimit = model.passcodeAttemptLimit
            let text = String(format: NSLocalizedString("lock.enter.passcode.view.model.incorrect.passcode", value: "Incorrect passcode. You have %d attempts.", comment: ""), passcodeAttemptLimit - numberOfAttempts)
            lockView.lockTitle.text = text
            lockView.shake()
            if numberOfAttempts == model.passcodeAttemptLimit {
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
