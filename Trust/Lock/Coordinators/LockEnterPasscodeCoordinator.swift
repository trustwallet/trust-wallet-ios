// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockEnterPasscodeCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    var protectionWasShown = false
    private let window: UIWindow = UIWindow()
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
            self?.protectionWasShown = bioUnlock
        }
    }
    func start() {
        guard lock.isPasscodeSet() else {
            return
        }
        protectionWasShown = true
        window.rootViewController = lockEnterPasscodeViewController
        window.makeKeyAndVisible()
        //Because of the usage of the window and rootViewController we are not able to receive properly view life circle events. So we should call this methods manually.
        lockEnterPasscodeViewController.showKeyboard()
        lockEnterPasscodeViewController.showBioMerickAuth()
    }
    func stop() {
        window.isHidden = true
    }
}
