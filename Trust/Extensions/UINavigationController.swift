// Copyright SIX DAY LLC. All rights reserved.

import UIKit

extension UINavigationController {
    //Remove after iOS 11.2 will patch this bug.
    func applyTintAdjustment() {
        navigationBar.tintAdjustmentMode = .normal
        navigationBar.tintAdjustmentMode = .automatic
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        var preferredStyle: UIStatusBarStyle
        if navigationBar.isKind(of: BrowserNavigationBar.self) {
            preferredStyle = .default
        } else {
            preferredStyle = .lightContent
        }
        return preferredStyle
    }

    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
}
