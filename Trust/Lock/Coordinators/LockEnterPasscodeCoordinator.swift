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
        //We should show passcode window on the top of all windows.
        self.window.windowLevel = UIWindowLevelStatusBar + 1.0
        self.model = model
        self.lock = lock
        lockEnterPasscodeViewController.willFinishWithResult = { [weak self] state in
            if state {
                self?.stop()
            }
        }
    }
    func start() {
        guard lock.isPasscodeSet() else {
             //Due to the lazy init and navigation flow we should call viewWillAppear manually.
            lockEnterPasscodeViewController.viewWillAppear(true)
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
