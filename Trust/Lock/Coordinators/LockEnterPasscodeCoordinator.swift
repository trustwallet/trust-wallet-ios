// Copyright DApps Platform Inc. All rights reserved.

import UIKit

final class LockEnterPasscodeCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    let window: UIWindow = UIWindow()
    private let model: LockEnterPasscodeViewModel
    private let lock: LockInterface
    private lazy var lockEnterPasscodeViewController: LockEnterPasscodeViewController = {
        return LockEnterPasscodeViewController(model: model)
    }()
    init(model: LockEnterPasscodeViewModel, lock: LockInterface = Lock()) {
        self.window.windowLevel = UIWindowLevelStatusBar + 1.0
        self.model = model
        self.lock = lock
        lockEnterPasscodeViewController.unlockWithResult = { [weak self] (state, bioUnlock) in
            if state {
                self?.stop()
            }
        }
    }

    func start() {
        guard lock.shouldShowProtection() else { return }

        window.rootViewController = lockEnterPasscodeViewController
        window.makeKeyAndVisible()
    }
    //This method should be refactored!!!
    func showAuthentication() {
        guard window.isKeyWindow, lock.isPasscodeSet() else {
            Lock().removeAutoLockTime()
            return
        }

        lockEnterPasscodeViewController.cleanUserInput()
    }

    func stop() {
        window.isHidden = true
    }
}
