// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class SplashCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    let navigationController: UINavigationController
    private lazy var splashViewController: SplashViewController = {
        return SplashViewController()
    }()
    init(
        navigationController: UINavigationController = NavigationController()
        ) {
        self.navigationController = navigationController
    }
    func start() {
        //We should add splashViewController on top of the navigation stack.
        navigationController.pushViewController(splashViewController, animated: false)
    }
    func dismiss() {
        navigationController.popViewController(animated: false)
    }
}
