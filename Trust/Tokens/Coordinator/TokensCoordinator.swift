// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol TokensCoordinatorDelegate: class {
    func didCancel(in coordinator: TokensCoordinator)
}

class TokensCoordinator: Coordinator {

    let navigationController: UINavigationController
    let account: Account
    var coordinators: [Coordinator] = []
    weak var delegate: TokensCoordinatorDelegate?

    init(
        navigationController: UINavigationController,
        account: Account
    ) {
        self.navigationController = navigationController
        self.account = account
    }

    func start() {
        showTokens()
    }

    func showTokens() {
        let controller = TokensViewController(account: account)
        controller.delegate = self
        if UIDevice.current.userInterfaceIdiom == .pad {
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .formSheet
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .cancel,
                target: self,
                action: #selector(dismiss)
            )
            navigationController.present(nav, animated: true, completion: nil)
        } else {
            navigationController.pushViewController(controller, animated: true)
        }
    }

    @objc func dismiss() {
        navigationController.dismiss(animated: true, completion: nil)
        delegate?.didCancel(in: self)
    }
}

extension TokensCoordinator: TokensViewControllerDelegate {
    func didSelect(token: Token, in viewController: UIViewController) {
        //
    }
}
