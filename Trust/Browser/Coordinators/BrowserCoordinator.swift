// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt

class BrowserCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    let session: WalletSession
    let keystore: Keystore
    let navigationController: UINavigationController
    lazy var rootViewController: BrowserViewController = {
        let controller = BrowserViewController(session: self.session)
        controller.delegate = self
        return controller
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore
    ) {
        self.navigationController = navigationController
        self.session = session
        self.keystore = keystore
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }

    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }
}

extension BrowserCoordinator: BrowserViewControllerDelegate {
    func didCall(action: DappAction) {
        switch session.account.type {
        case .real(let account):
            switch action {
            case .signTransaction(let unconfirmedTransaction):
                let configurator = TransactionConfigurator(
                    session: session,
                    account: account,
                    transaction: unconfirmedTransaction,
                    gasPrice: .none
                )

                let controller = ConfirmPaymentViewController(
                    session: session,
                    keystore: keystore,
                    configurator: configurator
                )
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
                controller.delegate = self

                let nav = UINavigationController(rootViewController: controller)
                navigationController.present(nav, animated: true, completion: nil)
            case .sign, .unknown:
                break
            }
        case .watch: break
        }

    }
}

extension BrowserCoordinator: ConfirmPaymentViewControllerDelegate {
    func didCompleted(transaction: SentTransaction, in viewController: ConfirmPaymentViewController) {
        navigationController.dismiss(animated: true, completion: nil)
    }
}
