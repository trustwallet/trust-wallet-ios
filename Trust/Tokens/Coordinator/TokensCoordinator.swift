// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class TokensCoordinator: Coordinator {

    let navigationController: UINavigationController
    let session: WalletSession
    var coordinators: [Coordinator] = []

    lazy var rootViewController: TokensViewController = {
        return self.makeTokensViewController()
    }()

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
        navigationController.viewControllers = [rootViewController]
    }

    func makeTokensViewController() -> TokensViewController {
        let controller = TokensViewController(account: session.account)
        controller.delegate = self
        return controller
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
