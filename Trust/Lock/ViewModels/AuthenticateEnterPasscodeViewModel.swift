// Copyright DApps Platform Inc. All rights reserved.

import Foundation

final class AuthenticateEnterPasscodeViewModel: LockViewModel, EnterPasscodeViewModelInterface {
    var initialLabelText: String {
        return R.string.localizable.lockEnterPasscodeViewModelInitial()
    }
    var tryAfterOneMinute: String {
        return R.string.localizable.lockEnterPasscodeViewModelTryAfterOneMinute()
    }
    var loginReason: String {
        return R.string.localizable.lockAuthenticateEnterPasscodeViewModelTouchId()
    }
}
