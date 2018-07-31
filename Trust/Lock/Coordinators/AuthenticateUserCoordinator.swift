// Copyright DApps Platform Inc. All rights reserved.

import Foundation

final class AuthenticateUserCoordinator: Coordinator {

    var coordinators: [Coordinator] = []
    private var waitForUnlockResult: UnlockResult?
    let navigationController: NavigationController
    private let model: LockEnterPasscodeViewModel
    private let lock: LockInterface
    private lazy var lockEnterPasscodeViewController: LockEnterPasscodeViewController = {
        return LockEnterPasscodeViewController(model: model)
    }()

    init(
        navigationController: NavigationController,
        model: LockEnterPasscodeViewModel = LockEnterPasscodeViewModel(),
        lock: LockInterface = Lock()
    ) {
        self.navigationController = navigationController
        self.model = model
        self.lock = lock

        lockEnterPasscodeViewController.unlockWithResult = { [weak self] (success, bioUnlock) in
            self?.waitForUnlockResult?(success, bioUnlock)
            if success {
                self?.stop()
            }
        }
    }

    func start(unlockResult: UnlockResult? = nil) {
        guard lock.shouldShowProtection() else { return }

        navigationController.present(lockEnterPasscodeViewController, animated: true)

        if let unlockResult = unlockResult {
            lockEnterPasscodeViewController.unlockWithResult = unlockResult
        }
    }

    func showAuthentication() {
        lockEnterPasscodeViewController.showKeyboard()
        lockEnterPasscodeViewController.showBioMerickAuth()
        lockEnterPasscodeViewController.cleanUserInput()
    }

    func stop() {
        navigationController.dismiss(animated: true)
    }
}
