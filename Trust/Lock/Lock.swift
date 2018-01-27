// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import SAMKeychain

class Lock {
    private struct Keys {
        static let service = "trust.lock"
        static let account = "trust.account"
    }
    private let standardDefaults = UserDefaults.standard
    private let passcodeAttempts = "passcodeAttempts"
    private let maxAttemptTime = "maxAttemptTime"
    func isPasscodeSet() -> Bool {
        return currentPasscode() != nil
    }
    func currentPasscode() -> String? {
        return SAMKeychain.password(forService: Keys.service, account: Keys.account)
    }
    func isPasscodeValid(passcode: String) -> Bool {
        return passcode == currentPasscode()
    }
    func setPasscode(passcode: String) {
        SAMKeychain.setPassword(passcode, forService: Keys.service, account: Keys.account)
    }
    func deletePasscode() {
        SAMKeychain.deletePassword(forService: Keys.service, account: Keys.account)
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
        standardDefaults.set(numberOfAttemptsSoFar, forKey: passcodeAttempts)
    }
    func recordedMaxAttemptTime() -> Date {
        return standardDefaults.object(forKey: maxAttemptTime) as! Date
    }
    func incorrectMaxAttemptTimeIsSet() -> Bool {
        return (standardDefaults.object(forKey: maxAttemptTime) != nil)
    }
    func recordIncorrectMaxAttemptTime() {
        standardDefaults.set(Date(), forKey: maxAttemptTime)
    }
    func removeIncorrectMaxAttemptTime() {
        standardDefaults.removeObject(forKey: maxAttemptTime)
    }
}
