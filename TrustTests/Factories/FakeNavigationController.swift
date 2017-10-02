// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class FakeNavigationController: UINavigationController {

    private var _presentedViewController: UIViewController?

    override var presentedViewController: UIViewController? {
        return _presentedViewController
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: false)
    }
    
    override func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)? = nil) {
        _presentedViewController = viewControllerToPresent
    }
}
