// Copyright DApps Platform Inc. All rights reserved.

import UIKit

extension UINavigationController {
    //Remove after iOS 11.2 will patch this bug.
    func applyTintAdjustment() {
        navigationBar.tintAdjustmentMode = .normal
        navigationBar.tintAdjustmentMode = .automatic
    }
}
