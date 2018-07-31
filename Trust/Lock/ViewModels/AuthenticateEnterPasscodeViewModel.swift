// Copyright DApps Platform Inc. All rights reserved.

import Foundation

final class AuthenticateEnterPasscodeViewModel: LockViewModel, EnterPasscodeViewModelInterface {
    var initialLabelText: String {
        return NSLocalizedString("lock.enter.passcode.view.model.initial", value: "Enter your passcode.", comment: "")
    }
    var tryAfterOneMinute: String {
        return NSLocalizedString("lock.enter.passcode.view.model.try.after.one.minute", value: "Try after 1 minute.", comment: "")
    }
    var loginReason: String {
        return NSLocalizedString("lock.authenticate.enter.passcode.view.model.touch.id", value: "Authenticating with Touch ID", comment: "")
    }
}
