// Copyright DApps Platform Inc. All rights reserved.

import UIKit
@testable import Trust

class FakeLockProtocol: LockInterface {

    var passcodeSet = true
    var showProtection = true
    var authorizeTransactions = true

    func isPasscodeSet() -> Bool {
        return passcodeSet
    }

    func shouldShowProtection() -> Bool {
        return isPasscodeSet() && showProtection
    }

    func authorizeTransactionsValue() -> Bool {
        return authorizeTransactions
    }

    func shouldAuthorizeTransactions() -> Bool {
        return isPasscodeSet() && authorizeTransactionsValue()
    }
}
