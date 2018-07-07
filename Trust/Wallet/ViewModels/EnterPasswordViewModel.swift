// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct EnterPasswordViewModel {

    var title: String {
        return NSLocalizedString("enterPassword.navigation.title", value: "Backup Password", comment: "")
    }

    var headerSectionText: String {
        return NSLocalizedString("enterPassword.password.header.placeholder", value: "Password used to encrypt your backup file to keep it secure!", comment: "")
    }

    var passwordFieldPlaceholder: String {
        return NSLocalizedString("enterPassword.password.textField.placeholder", value: "Password", comment: "")
    }

    var confirmPasswordFieldPlaceholder: String {
        return NSLocalizedString("enterPassword.confirmPassword.textField.placeholder", value: "Confirm Password", comment: "")
    }

    var passwordNoMatch: String {
        return NSLocalizedString("enterPassword.passwordNoMatch.error", value: "Passwords don't match!", comment: "")
    }
}
