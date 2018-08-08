// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import SAMKeychain
import KeychainSwift

protocol LockInterface {
    func isPasscodeSet() -> Bool
    func shouldShowProtection() -> Bool
}

final class Lock: LockInterface {

    private struct Keys {
        static let service = "trust.lock"
        static let account = "trust.account"
    }

    private let passcodeAttempts = "passcodeAttempts"
    private let maxAttemptTime = "maxAttemptTime"
    private let autoLockType = "autoLockType"
    private let autoLockTime = "autoLockTime"
    private let keychain: KeychainSwift

    init(keychain: KeychainSwift = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix)) {
        self.keychain = keychain
    }

    func shouldShowProtection() -> Bool {
        return isPasscodeSet() && autoLockTriggered()
    }

    func isPasscodeSet() -> Bool {
        return currentPasscode() != nil
    }

    func currentPasscode() -> String? {
        return SAMKeychain.password(forService: Keys.service, account: Keys.account)
    }

    func isPasscodeValid(passcode: String) -> Bool {
        return passcode == currentPasscode()
    }

    func setAutoLockType(type: AutoLock) {
         keychain.set(String(type.rawValue), forKey: autoLockType)
    }

    func getAutoLockType() -> AutoLock {
        let id = keychain.get(autoLockType)
        guard let type = id, let intType = Int(type), let autoLock = AutoLock(rawValue: intType) else {
            return .immediate
        }
        return autoLock
    }

    func setAutoLockTime() {
        guard isPasscodeSet(), keychain.get(autoLockTime) == nil else { return }
        let timeString = dateFormatter().string(from: Date())
        keychain.set(timeString, forKey: autoLockTime)
    }

    func getAutoLockTime() -> Date {
        guard let timeString = keychain.get(autoLockTime), let time = dateFormatter().date(from: timeString) else {
            return Date()
        }
        return time
    }

    func setPasscode(passcode: String) {
        SAMKeychain.setPassword(passcode, forService: Keys.service, account: Keys.account)
    }

    func deletePasscode() {
        SAMKeychain.deletePassword(forService: Keys.service, account: Keys.account)
        resetPasscodeAttemptHistory()
        setAutoLockType(type: AutoLock.immediate)
    }

    func numberOfAttempts() -> Int {
        guard let attempts = keychain.get(passcodeAttempts) else {
            return 0
        }
        return Int(attempts)!
    }

    func resetPasscodeAttemptHistory() {
         keychain.delete(passcodeAttempts)
    }

    func recordIncorrectPasscodeAttempt() {
        var numberOfAttemptsSoFar = numberOfAttempts()
        numberOfAttemptsSoFar += 1
        keychain.set(String(numberOfAttemptsSoFar), forKey: passcodeAttempts)
    }

    func recordedMaxAttemptTime() -> Date? {
        guard let timeString = keychain.get(maxAttemptTime) else {
            return nil
        }
        return dateFormatter().date(from: timeString)
    }

    func incorrectMaxAttemptTimeIsSet() -> Bool {
        guard let timeString = keychain.get(maxAttemptTime), !timeString.isEmpty  else {
            return false
        }
        return true
    }

    func recordIncorrectMaxAttemptTime() {
        let timeString = dateFormatter().string(from: Date())
        keychain.set(timeString, forKey: maxAttemptTime)
    }

    func removeIncorrectMaxAttemptTime() {
        keychain.delete(maxAttemptTime)
    }

    func removeAutoLockTime() {
        keychain.delete(autoLockTime)
    }

    private func dateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.medium
        return dateFormatter
    }

    private func autoLockTriggered() -> Bool {
        let type = getAutoLockType()
        switch type {
        case .immediate:
            return true
        default:
            return timeOutInterval(for: type)
        }
    }

    private func timeOutInterval(for type: AutoLock) -> Bool {
        let elapsed = Date().timeIntervalSince(getAutoLockTime())
        let intervalPassed = Int(elapsed) >= type.interval
        return intervalPassed
    }

    func clear() {
        deletePasscode()
        resetPasscodeAttemptHistory()
        removeIncorrectMaxAttemptTime()
        removeAutoLockTime()
    }
}
