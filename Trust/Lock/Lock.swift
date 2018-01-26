// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import SSKeychain

class Lock {
    struct Keys {
        static let service = "trust.lock"
        static let account = "trust.account"
    }
    func isPasscodeSet() -> Bool {
        return currentPasscode() != nil
    }
    func currentPasscode() -> String? {
        return SSKeychain.password(forService: Keys.service, account: Keys.account)
    }
    func isPasscodeValid(passcode: String) -> Bool {
        return passcode == currentPasscode()
    }
    func setPasscode(passcode: String) {
        SSKeychain.setPassword(passcode, forService: Keys.service, account: Keys.account)
    }
    func deletePasscode() {
        SSKeychain.deletePassword(forService: Keys.service, account: Keys.account)
    }
}
