// Copyright SIX DAY LLC. All rights reserved.

import UIKit

extension UINavigationController {
    //Remove after iOS 11.2 will patch this bug.
    func applyTintAdjustment() {
        navigationBar.tintAdjustmentMode = .normal
        navigationBar.tintAdjustmentMode = .automatic
    }

    @discardableResult
    static func openFormSheet(
        for controller: UIViewController,
        in navigationController: UINavigationController,
        barItem: UIBarButtonItem
    ) -> UIViewController {
        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.navigationItem.leftBarButtonItem = barItem
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .formSheet
            navigationController.present(nav, animated: true, completion: nil)
        } else {
            navigationController.pushViewController(controller, animated: true)
        }
        return controller
    }

    open override var preferredStatusBarStyle: UIStatusBarStyle {
        var preferredStyle: UIStatusBarStyle
        if topViewController is MasterBrowserViewController {
            preferredStyle = .default
        } else {
            preferredStyle = .lightContent
        }
        return preferredStyle
    }
}
