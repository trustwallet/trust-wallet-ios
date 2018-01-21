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
        navigationController.viewControllers = [rootViewController]
    }
    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}
