// Copyright DApps Platform Inc. All rights reserved.

import UIKit

protocol LockCreatePasscodeCoordinatorDelegate: class {
    func didCancel(in coordinator: LockCreatePasscodeCoordinator)
}

final class LockCreatePasscodeCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private let model: LockCreatePasscodeViewModel
    let navigationController: NavigationController
    weak var delegate: LockCreatePasscodeCoordinatorDelegate?

    lazy var lockViewController: LockCreatePasscodeViewController = {
        let controller = LockCreatePasscodeViewController(model: model)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        return controller
    }()

    init(
        navigationController: NavigationController = NavigationController(),
        model: LockCreatePasscodeViewModel
    ) {
        self.navigationController = navigationController
        self.model = model
    }

    func start() {
        navigationController.viewControllers = [lockViewController]
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}
