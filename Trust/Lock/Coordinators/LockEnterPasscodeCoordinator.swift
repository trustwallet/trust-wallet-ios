// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockEnterPasscodeCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    var passcodeViewIsActive = false
    private let window: UIWindow
    private let model: LockEnterPasscodeViewModel
    private let lock: LockInterface
    private lazy var lockEnterPasscodeViewController: LockEnterPasscodeViewController = {
        return LockEnterPasscodeViewController(model: model)
    }()
    init(window: UIWindow, model: LockEnterPasscodeViewModel, lock: LockInterface = Lock()) {
        self.window = window
        self.model = model
        self.lock = lock
        lockEnterPasscodeViewController.willFinishWithResult = { [weak self] state in
            if state {
                self?.stop()
            }
        }
    }
    func start() {
        guard !passcodeViewIsActive && lock.isPasscodeSet() else {
            return
        }
        passcodeViewIsActive = true
        window.rootViewController = lockEnterPasscodeViewController
        window.makeKeyAndVisible()
    }
    func stop() {
        passcodeViewIsActive = false
        window.isHidden = true
    }
}
