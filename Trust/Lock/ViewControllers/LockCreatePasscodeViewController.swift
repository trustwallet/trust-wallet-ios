// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockCreatePasscodeViewController: LockPasscodeViewController {
    private lazy var lockEnterPasscodeViewModel: LockEnterPasscodeViewModel? = {
        return self.model as? LockEnterPasscodeViewModel
    }()
    override func viewDidLoad() {
        self.lockView.lockTitle.text = lockEnterPasscodeViewModel?.initialLabelText
    }
}
