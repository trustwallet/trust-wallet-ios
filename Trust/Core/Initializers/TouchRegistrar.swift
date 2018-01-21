// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import VENTouchLock
import SSKeychain

class TouchRegistrar {

    struct Keys {
        static let service = "trust.lock"
        static let account = "trust.account"
    }
    private let keystore: Keystore

    init(
        keystore: Keystore
    ) {
        self.keystore = keystore
    }

    func register() {
        if !keystore.hasWallets {
            unregister()
        }

        VENTouchLock.sharedInstance().setKeychainService(
            Keys.service,
            keychainAccount: Keys.account,
            touchIDReason: "Use your fingerprint to access your wallet",
            passcodeAttemptLimit: 5,
            splashViewControllerClass: ProtectionViewController.self
        )
    }

    func unregister() {
        SSKeychain.deletePassword(forService: Keys.service, account: Keys.account)
        VENTouchLock.sharedInstance().deletePasscode()
        VENTouchLock.setShouldUseTouchID(false)
    }
}
