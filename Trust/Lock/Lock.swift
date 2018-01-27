// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import SSKeychain

class Lock {
    private struct Keys {
        static let service = "trust.lock"
        static let account = "trust.account"
    }
    private let standardDefaults = UserDefaults.standard
    private let passcodeAttempts = "passcodeAttempts"
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
        resetPasscodeAttemptHistory()
    }
    func numberOfAttempts() -> Int {
        return standardDefaults.integer(forKey: passcodeAttempts)
    }
    func resetPasscodeAttemptHistory() {
        standardDefaults.removeObject(forKey: passcodeAttempts)
    }
    func recordIncorrectPasscodeAttempt() {
        var numberOfAttemptsSoFar = standardDefaults.integer(forKey: passcodeAttempts)
        numberOfAttemptsSoFar += 1
        standardDefaults.set(passcodeAttempts, forKey: passcodeAttempts)
    }
}
