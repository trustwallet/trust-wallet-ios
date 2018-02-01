// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt
import TrustKeystore

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
        session: WalletSession,
        keystore: Keystore
    ) {
        self.navigationController = UINavigationController(navigationBarClass: BrowserNavigationBar.self, toolbarClass: nil)
        self.session = session
        self.keystore = keystore
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }

    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    private func executeTransaction(account: Account, action: DappAction, callbackID: Int, transaction: UnconfirmedTransaction, type: ConfirmType) {
        let configurator = TransactionConfigurator(
            session: session,
            account: account,
            transaction: transaction
        )
        let coordinator = ConfirmCoordinator(
            navigationController: UINavigationController(),
            session: session,
            configurator: configurator,
            keystore: keystore,
            account: account,
            type: type
        )
        addCoordinator(coordinator)
        coordinator.didCompleted = { [unowned self] result in
            switch result {
            case .success(let type):
                switch type {
                case .signedTransaction(let data):
                    let callback = DappCallback(id: callbackID, value: .signTransaction(data))
                    self.rootViewController.notifyFinish(callbackID: callbackID, value: .success(callback))
                case .sentTransaction(let transaction):
                    let data = Data(hex: transaction.id)
                    let callback = DappCallback(id: callbackID, value: .sendTransaction(data))
                    self.rootViewController.notifyFinish(callbackID: callbackID, value: .success(callback))
                    self.delegate?.didSentTransaction(transaction: transaction, in: self)
                }
            case .failure:
                self.rootViewController.notifyFinish(
                    callbackID: callbackID,
                    value: .failure(DAppError.cancelled)
                )
            }
            self.removeCoordinator(coordinator)
            self.navigationController.dismiss(animated: true, completion: nil)
        }
        coordinator.start()
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }
}

extension BrowserCoordinator: BrowserViewControllerDelegate {
    func didCall(action: DappAction, callbackID: Int) {
        switch session.account.type {
        case .real(let account):
            switch action {
            case .signTransaction(let unconfirmedTransaction):
                executeTransaction(account: account, action: action, callbackID: callbackID, transaction: unconfirmedTransaction, type: .sign)
            case .sendTransaction(let unconfirmedTransaction):
                executeTransaction(account: account, action: action, callbackID: callbackID, transaction: unconfirmedTransaction, type: .signThenSend)
            case .signMessage(let hexMessage):
                let data = Data(hexString: hexMessage)!
                let message = String(data: data, encoding: .utf8)!

                let coordinator = SignMessageCoordinator(
                    navigationController: navigationController,
                    keystore: keystore,
                    account: account
                )
                coordinator.didComplete = { [unowned self] result in
                    switch result {
                    case .success(let data):
                        let callback = DappCallback(id: callbackID, value: .signMessage(data))
                        self.rootViewController.notifyFinish(callbackID: callbackID, value: .success(callback))
                    case .failure:
                        self.rootViewController.notifyFinish(callbackID: callbackID, value: .failure(DAppError.cancelled))
                    }
                    self.removeCoordinator(coordinator)
                }
                coordinator.delegate = self
                addCoordinator(coordinator)
                coordinator.start(with: message)
            case .unknown:
                break
            }
        case .watch: break
        }
    }
}

extension BrowserCoordinator: SignMessageCoordinatorDelegate {
    func didCancel(in coordinator: SignMessageCoordinator) {
        removeCoordinator(coordinator)
    }
}

extension BrowserCoordinator: ConfirmCoordinatorDelegate {
    func didCancel(in coordinator: ConfirmCoordinator) {
        navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}
