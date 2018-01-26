// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class LockCreatePasscodeCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private let model: LockCreatePasscodeViewModel
    private let navigationController: UINavigationController
    private lazy var lockViewController: LockCreatePasscodeViewController = {
        return LockCreatePasscodeViewController(model: model)
    }()
    init(navigationController: UINavigationController, model: LockCreatePasscodeViewModel) {
        self.navigationController = navigationController
        self.model = model
    }
    func start() {
        navigationController.viewControllers = [lockViewController]
    }
    func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}
