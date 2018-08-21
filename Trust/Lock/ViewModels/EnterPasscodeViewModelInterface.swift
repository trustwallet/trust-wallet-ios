// Copyright DApps Platform Inc. All rights reserved.

import Foundation

protocol EnterPasscodeViewModelInterface: class {
    var loginReason: String { get }
}

extension EnterPasscodeViewModelInterface {
    var initialLabelText: String {
        return R.string.localizable.lockEnterPasscodeViewModelInitial()
    }
    var tryAfterOneMinute: String {
        return R.string.localizable.lockEnterPasscodeViewModelTryAfterOneMinute()
    }
}
