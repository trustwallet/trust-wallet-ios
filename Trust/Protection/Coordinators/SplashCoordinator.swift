// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class SplashCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private var splashViewIsActive = false
    private let window: UIWindow
    private var splashView: SplashView
    init(window: UIWindow) {
        self.window = window
        self.splashView = SplashView()
    }
    func start() {
        guard Lock().isPasscodeSet() else {
            return
        }
        window.isHidden = false
        window.addSubview(splashView)
        window.bringSubview(toFront: splashView)
        splashView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            splashView.topAnchor.constraint(equalTo: window.topAnchor),
            splashView.leadingAnchor.constraint(equalTo: window.leadingAnchor),
            splashView.bottomAnchor.constraint(equalTo: window.bottomAnchor),
            splashView.trailingAnchor.constraint(equalTo: window.trailingAnchor),
        ])
    }
    func dismiss() {
        splashView.removeFromSuperview()
    }
}
