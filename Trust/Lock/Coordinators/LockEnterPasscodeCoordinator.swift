// Copyright DApps Platform Inc. All rights reserved.

import UIKit

typealias UnlockResult = ((_ success: Bool, _ bioUnlock: Bool) -> Void)

final class LockEnterPasscodeCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    let window: UIWindow = UIWindow()
    private let model: LockEnterPasscodeViewModel
    private let lock: LockInterface
    private lazy var lockEnterPasscodeViewController: LockEnterPasscodeViewController = {
        return LockEnterPasscodeViewController(model: model)
    }()
    private var waitForUnlockResult: UnlockResult?
    init(model: LockEnterPasscodeViewModel, lock: LockInterface = Lock()) {
        self.window.windowLevel = UIWindowLevelStatusBar + 1.0
        self.model = model
        self.lock = lock
        lockEnterPasscodeViewController.unlockWithResult = { [weak self] (state, bioUnlock) in
            self?.waitForUnlockResult?(state, bioUnlock)
            if state {
                self?.stop()
            }
        }
    }

    func start(unlockResult: UnlockResult? = nil) {
        guard lock.shouldShowProtection() else { return }

        window.rootViewController = lockEnterPasscodeViewController
        window.makeKeyAndVisible()

        if let unlockResult = unlockResult {
            lockEnterPasscodeViewController.unlockWithResult = unlockResult
        }
    }

    //This method should be refactored!!!
    func showAuthentication() {
        guard window.isKeyWindow, lock.isPasscodeSet() else {
            Lock().removeAutoLockTime()
            return
        }

        lockEnterPasscodeViewController.showKeyboard()
        lockEnterPasscodeViewController.showBioMerickAuth()
        lockEnterPasscodeViewController.cleanUserInput()
    }

    func stop() {
        window.isHidden = true
    }
}
