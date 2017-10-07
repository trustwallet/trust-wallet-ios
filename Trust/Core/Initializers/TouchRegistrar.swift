// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import VENTouchLock

class TouchRegistrar {

    struct Keys {
        static let service = "trust.lock"
        static let account = "trust.account"
    }

    init() {}

    func register() {
        VENTouchLock.sharedInstance().setKeychainService(
            Keys.service,
            keychainAccount: Keys.account,
            touchIDReason: "Use your fingerprint to access your wallet",
            passcodeAttemptLimit: 5,
            splashViewControllerClass: SplashViewController.self
        )
        VENTouchLock.sharedInstance().backgroundLockVisible = true
        VENTouchLockAppearance().splashShouldEmbedInNavigationController = true
        VENTouchLockAppearance().touchIDCancelPresentsPasscodeViewController = false
    }

    func unregister() {
        VENTouchLock.sharedInstance().deletePasscode()
    }
}
