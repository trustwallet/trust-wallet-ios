// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockCreatePasscodeViewController: LockPasscodeViewController {
    private lazy var lockCreatePasscodeViewModel: LockCreatePasscodeViewModel? = {
        return self.model as? LockCreatePasscodeViewModel
    }()
    private var firstPasscode: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = lockCreatePasscodeViewModel?.title
        self.lockView.lockTitle.text = lockCreatePasscodeViewModel?.initialLabelText
    }
    override func enteredPasscode(_ passcode: String) {
        super.enteredPasscode(passcode)
        if let first = firstPasscode {
            if passcode == first {
                //Set path to lock manager
                finish(withResult: true, animated: true)
            } else {
                lockView.shake()
                firstPasscode = nil
                showFirstPasscodeView()
            }
        } else {
            firstPasscode = passcode
            showConfirmPasscodeView()
        }
    }
    private func showFirstPasscodeView() {
        self.lockView.lockTitle.text = lockCreatePasscodeViewModel?.initialLabelText
    }
    private func showConfirmPasscodeView() {
        self.lockView.lockTitle.text = lockCreatePasscodeViewModel?.confirmLabelText
    }
}
