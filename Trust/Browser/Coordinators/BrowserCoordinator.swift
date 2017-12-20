// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class BrowserCoordinator: Coordinator {
    var coordinators: [Coordinator] = []

    let navigationController: UINavigationController
    let rootViewController = BrowserViewController()

    init(
        navigationController: UINavigationController = NavigationController()
    ) {
        self.navigationController = navigationController
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }
}
