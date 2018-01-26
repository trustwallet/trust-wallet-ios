// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private let window: UIWindow
    private let model: LockViewModel
    private lazy var lockViewController: LockPasscodeViewController = {
        return LockPasscodeViewController(model: model)
    }()
    init(window: UIWindow, model: LockViewModel) {
        self.window = window
        self.model = model
    }
    func start() {
        window.rootViewController = lockViewController
        window.makeKeyAndVisible()
    }
    func dismiss() {
        window.isHidden = true
    }
}
