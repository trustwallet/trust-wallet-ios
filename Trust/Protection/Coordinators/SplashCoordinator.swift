// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class SplashCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private var splashViewIsActive = false
    private let window: UIWindow
    private lazy var splashViewController: SplashViewController = {
        return SplashViewController()
    }()
    init(window: UIWindow) {
        self.window = window
    }
    func start() {
        guard !splashViewIsActive else {
            return
        }
        splashViewIsActive = true
        window.rootViewController = splashViewController
        window.makeKeyAndVisible()
    }
    func dismiss() {
        splashViewIsActive = false
        window.isHidden = true
    }
}
