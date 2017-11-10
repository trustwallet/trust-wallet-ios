// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol TokensCoordinatorDelegate: class {
    func didCancel(in coordinator: TokensCoordinator)
}

class TokensCoordinator: Coordinator {

    let navigationController: UINavigationController
    let session: WalletSession
    var coordinators: [Coordinator] = []
    weak var delegate: TokensCoordinatorDelegate?

    init(
        navigationController: UINavigationController = NavigationController(),
        session: WalletSession
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
    }

    func start() {
        showTokens()
    }

    func showTokens() {
        let controller = TokensViewController(account: session.account)
        controller.delegate = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(dismiss)
        )
        navigationController.viewControllers = [controller]
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    func showPaymentFlow(for type: PaymentFlow, session: WalletSession) {
        let coordinator = PaymentCoordinator(
            flow: type,
            session: session
        )
        coordinator.delegate = self
        coordinator.start()
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
        addCoordinator(coordinator)
    }
}

extension TokensCoordinator: TokensViewControllerDelegate {
    func didSelect(token: Token, in viewController: UIViewController) {
        showPaymentFlow(for: .send(type: .token(token)), session: session)
    }
}

extension TokensCoordinator: PaymentCoordinatorDelegate {
    func didCancel(in coordinator: PaymentCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}
