// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class ExchangeCoordinator: Coordinator {

    let navigationController: UINavigationController
    var rootViewController: UIViewController = {
        return ExchangeViewController()
    }()
    var coordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController = UINavigationController()
    ) {
        self.navigationController = navigationController
    }

    func start() {
        navigationController.viewControllers = [
            rootViewController,
        ]
    }
}
