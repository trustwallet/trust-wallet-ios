// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol LockCreatePasscodeCoordinatorDelegate: class {
    func didCancel(in coordinator: LockCreatePasscodeCoordinator)
}

class LockCreatePasscodeCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    private let model: LockCreatePasscodeViewModel
    let navigationController: UINavigationController
    weak var delegate: LockCreatePasscodeCoordinatorDelegate?

    lazy var lockViewController: LockCreatePasscodeViewController = {
        let controller = LockCreatePasscodeViewController(model: model)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        return controller
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
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
