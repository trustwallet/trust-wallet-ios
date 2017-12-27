// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class BrowserCoordinator: Coordinator {
    var coordinators: [Coordinator] = []

    let session: WalletSession
    let navigationController: UINavigationController
    lazy var rootViewController: BrowserViewController = {
        return BrowserViewController(session: self.session)
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
        session: WalletSession
    ) {
        self.navigationController = navigationController
        self.session = session
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }
}
