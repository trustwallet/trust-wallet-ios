// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class TokensCoordinator: Coordinator {

    let navigationController: UINavigationController
    let session: WalletSession
    let keystore: Keystore
    var coordinators: [Coordinator] = []
    let storage: TokensDataStore

    lazy var tokensViewController: TokensViewController = {
        let controller = TokensViewController(
            account: session.account,
            dataStore: storage
        )
        controller.delegate = self
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(edit))
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addToken))
        return controller
    }()

    lazy var rootViewController: TokensViewController = {
        return self.tokensViewController
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore,
        tokensStorage: TokensDataStore
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.keystore = keystore
        self.storage = tokensStorage
    }

    func start() {
        showTokens()
    }

    func showTokens() {
        navigationController.viewControllers = [rootViewController]
    }

    func showPaymentFlow(for type: PaymentFlow) {
        let coordinator = PaymentCoordinator(
            flow: type,
            session: session,
            keystore: keystore
        )
        coordinator.delegate = self
        coordinator.start()
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
        addCoordinator(coordinator)
    }

    func newTokenViewController() -> NewTokenViewController {
        let controller = NewTokenViewController()
        controller.delegate = self
        return controller
    }

    @objc func addToken() {
        let controller = newTokenViewController()
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .formSheet
        navigationController.present(nav, animated: true, completion: nil)
    }

    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
    }

    @objc func edit() {
        let controller = EditTokensViewController(
            session: session,
            storage: storage
        )
        navigationController.pushViewController(controller, animated: true)
    }
}

extension TokensCoordinator: TokensViewControllerDelegate {
    func didSelect(token: TokenObject, in viewController: UIViewController) {
        switch token.type {
        case .ether:
            showPaymentFlow(for: .send(type: .ether(destination: .none)))
        case .token:
            showPaymentFlow(for: .send(type: .token(token)))
        }
    }

    func didDelete(token: TokenObject, in viewController: UIViewController) {
        storage.delete(tokens: [token])
        tokensViewController.fetch()
    }
}

extension TokensCoordinator: PaymentCoordinatorDelegate {
    func didCancel(in coordinator: PaymentCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension TokensCoordinator: NewTokenViewControllerDelegate {
    func didAddToken(token: ERC20Token, in viewController: NewTokenViewController) {
        storage.addCustom(token: token)
        tokensViewController.fetch()
        dismiss()
    }
}
