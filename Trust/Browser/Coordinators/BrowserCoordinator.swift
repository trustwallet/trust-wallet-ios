// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt

protocol BrowserCoordinatorDelegate: class {
    func didSentTransaction(transaction: SentTransaction, in coordinator: BrowserCoordinator)
}

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
    weak var delegate: BrowserCoordinatorDelegate?

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
    func didCall(action: DappAction, callbackID: Int) {
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
                //addCoordinator(configurator)

                let controller = ConfirmPaymentViewController(
                    session: session,
                    keystore: keystore,
                    configurator: configurator,
                    confirmType: .sign
                )
                controller.didCompleted = { type in
                    switch type {
                    case .signedTransaction(let data):
                        let callback = DappCallback(id: callbackID, value: .signTransaction(data))
                        self.rootViewController.notifyFinish(callback: callback)
                    case .sentTransaction(let transaction):
                        self.delegate?.didSentTransaction(transaction: transaction, in: self)
                    }
                    self.navigationController.dismiss(animated: true, completion: nil)
                }
                controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))

                let nav = UINavigationController(rootViewController: controller)
                navigationController.present(nav, animated: true, completion: nil)
            case .signMessage(let message):
                let coordinator = SignMessageCoordinator(
                    navigationController: navigationController,
                    keystore: keystore,
                    account: account
                )
                coordinator.start(with: message)
            case .unknown:
                break
            }
        case .watch: break
        }

    }
}
