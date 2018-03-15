// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class SplashCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private let window: UIWindow
    init(window: UIWindow) {
        self.window = window
    }
    func start() {
        window.rootViewController = SplashViewController()
        window.isHidden = false
    }
    func stop() {
        window.isHidden = true
    }
}
