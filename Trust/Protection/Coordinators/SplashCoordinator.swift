// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class SplashCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private let window: UIWindow
    private lazy var splashViewController: SplashViewController = {
        return SplashViewController()
    }()
    init(window: UIWindow) {
        self.window = window
    }
    func start() {
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
    }
    func dismiss() {
        window.isHidden = true
    }
}
