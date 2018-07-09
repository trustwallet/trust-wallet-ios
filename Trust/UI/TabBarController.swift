// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class TabBarController: UITabBarController {

    private var previousController: UIViewController?

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TabBarController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if self.previousController == nil {
            self.previousController = viewController
        }

        if self.previousController == viewController {
            if let nav = viewController as? UINavigationController,
                nav.viewControllers.count < 2,
                let controller = nav.viewControllers.first as? Scrollable {
                controller.scrollOnTop()
            }
        }
        self.previousController = viewController
        return true
    }
}
