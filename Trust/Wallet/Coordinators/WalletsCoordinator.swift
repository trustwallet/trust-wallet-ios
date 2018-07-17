// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

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
        return walletController
    }()

    lazy var walletController: WalletsViewController = {
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
        walletController.fetch()
    }
}

extension WalletsCoordinator: WalletsViewControllerDelegate {
    func didSelect(wallet: WalletInfo, account: Account, in controller: WalletsViewController) {
        keystore.store(object: wallet.info, fields: [
            .setAccount(account.description),
        ])

        delegate?.didSelect(wallet: wallet, in: self)
    }
}
