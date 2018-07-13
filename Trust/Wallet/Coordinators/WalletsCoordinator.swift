// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

protocol WalletsCoordinatorDelegate: class {
    func didSelect(wallet: WalletInfo, in coordinator: WalletsCoordinator)
    func didCancel(in coordinator: WalletsCoordinator)
}

class WalletsCoordinator: Coordinator {

    var coordinators: [Coordinator] = []
    let keystore: Keystore
    let navigationController: NavigationController
    weak var delegate: WalletsCoordinatorDelegate?

    lazy var rootViewController: UIViewController = {
        let controller = WalletsViewController(keystore: keystore)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismiss)
        )
        controller.delegate = self
        return controller
    }()

    init(
        keystore: Keystore,
        navigationController: NavigationController = NavigationController()
    ) {
        self.keystore = keystore
        self.navigationController = navigationController
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }
}

extension WalletsCoordinator: WalletsViewControllerDelegate {
    func didSelect(wallet: WalletInfo, in controller: WalletsViewController) {
        delegate?.didSelect(wallet: wallet, in: self)
    }
}
