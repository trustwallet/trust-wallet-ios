// Copyright SIX DAY LLC. All rights reserved.

import UIKit

extension UINavigationController {
    //Remove after iOS 11.2 will patch this bug.
    func applyTintAdjustment() {
        navigationBar.tintAdjustmentMode = .normal
        navigationBar.tintAdjustmentMode = .automatic
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .lightContent
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
}
