// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockEnterPasscodeCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private let window: UIWindow
    private let model: LockEnterPasscodeViewModel
    private lazy var lockEnterPasscodeViewController: LockEnterPasscodeViewController = {
        return LockEnterPasscodeViewController(model: model)
    }()
    init(window: UIWindow, model: LockEnterPasscodeViewModel) {
        self.window = window
        self.model = model
        lockEnterPasscodeViewController.willFinishWithResult = { [weak self] state in
            if state {
                self?.dismiss()
            }
        }
    }
    func start() {
        window.rootViewController = lockEnterPasscodeViewController
        window.makeKeyAndVisible()
    }
    func dismiss() {
        window.isHidden = true
    }
}
