// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct EnterPasswordViewModel {

    var title: String {
        return NSLocalizedString("enterPassword.navigation.title", value: "Backup Password", comment: "")
    }

    var headerSectionText: String {
        return "Password used to encrypt you backup file to keep it safe"
    }

    var passwordFieldPlaceholder: String {
        return NSLocalizedString("enterPassword.password.textField.placeholder", value: "Password", comment: "")
    }

    var confirmPasswordFieldPlaceholder: String {
        return NSLocalizedString("enterPassword.confirmPassword.textField.placeholder", value: "Confirm Password", comment: "")
    }
}
