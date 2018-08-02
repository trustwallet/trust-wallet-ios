// Copyright DApps Platform Inc. All rights reserved.

import UIKit

final class LockEnterPasscodeViewModel: LockViewModel, EnterPasscodeViewModelInterface {
    var initialLabelText: String {
        return R.string.localizable.lockEnterPasscodeViewModelInitial()
    }
    var tryAfterOneMinute: String {
        return R.string.localizable.lockEnterPasscodeViewModelTryAfterOneMinute()
    }
    var loginReason: String {
        return R.string.localizable.lockEnterPasscodeViewModelTouchId()
    }
}
