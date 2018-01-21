// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class SplashCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    let navigationController: UINavigationController
    lazy var rootViewController: SplashViewController = {
        return SplashViewController()
    }()
    init(
        navigationController: UINavigationController = NavigationController()
        ) {
        self.navigationController = navigationController
    }
    func start() {
        navigationController.pushViewController(rootViewController, animated: false)
    }
    func dismiss() {
        navigationController.popViewController(animated: false)
    }
}
