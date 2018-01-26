// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockViewModel {
    lazy var charCount: Int = {
        return 5
    }()
    lazy var passcodeAttemptLimit: Int = {
        return 5
    }()
}
