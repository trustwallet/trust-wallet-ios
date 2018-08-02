// Copyright DApps Platform Inc. All rights reserved.

import Foundation

final class AuthenticateEnterPasscodeViewModel: LockViewModel, EnterPasscodeViewModelInterface {
    var loginReason: String {
        return R.string.localizable.lockAuthenticateEnterPasscodeViewModelTouchId()
    }
}
