// Copyright DApps Platform Inc. All rights reserved.

import Foundation

class MarketCoordinator: Coordinator {
    var coordinators: [Coordinator] = []

    let navigationController: NavigationController

    lazy var rootViewController: MarketViewController = {
        let controller = MarketViewController()
        return controller
    }()

    init(
        navigationController: NavigationController = NavigationController()
        ) {
        self.navigationController = navigationController
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }
}
