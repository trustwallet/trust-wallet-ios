// Copyright DApps Platform Inc. All rights reserved.

import UIKit

final class LockEnterPasscodeViewModel: LockViewModel, EnterPasscodeViewModelInterface {
    var loginReason: String {
        return R.string.localizable.lockEnterPasscodeViewModelTouchId()
    }
}
