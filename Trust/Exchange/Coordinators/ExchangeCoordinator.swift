// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class ExchangeCoordinator: Coordinator {

    let navigationController: UINavigationController
    let session: WalletSession

    lazy var rootViewController: UIViewController = {
        let controller = ExchangeViewController()
        controller.delegate = self
        return controller
    }()
    var coordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController = UINavigationController(),
        session: WalletSession
    ) {
        self.navigationController = navigationController
        self.session = session
    }

    func start() {
        navigationController.viewControllers = [
            rootViewController,
        ]
    }
}

extension ExchangeCoordinator: ExchangeViewControllerDelegate {
    func didPress(from: SubmitExchangeToken, to: SubmitExchangeToken, in viewController: ExchangeViewController) {

        let transaction = UnconfirmedTransaction(
            transferType: .exchange(from: from, to: to),
            amount: from.amount,
            address: Address(address: "0x11") // TODO FIX IT
        )

        let viewModel = ConfirmTransactionHeaderViewModel(
            transaction: transaction,
            config: Config()
        )

        let controller = ConfirmPaymentViewController(
            session: session,
            transaction: transaction,
            viewModel: viewModel
        )
        controller.delegate = self
        navigationController.pushViewController(controller, animated: true)
    }
}

extension ExchangeCoordinator: ConfirmPaymentViewControllerDelegate {
    func didCompleted(transaction: SentTransaction, in viewController: ConfirmPaymentViewController) {
        navigationController.popViewController(animated: true)
        navigationController.displaySuccess(title: "Exchange \(transaction.id)")
    }
}
