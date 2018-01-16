// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class ExchangeCoordinator: Coordinator {

    let navigationController: UINavigationController
    let session: WalletSession
    let keystore: Keystore

    lazy var rootViewController: UIViewController = {
        let controller = ExchangeViewController(
            session: self.session
        )
        //controller.delegate = self
        return controller
    }()
    var coordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController = UINavigationController(),
        session: WalletSession,
        keystore: Keystore
    ) {
        self.navigationController = navigationController
        self.session = session
        self.keystore = keystore
    }

    func start() {
        navigationController.viewControllers = [
            rootViewController,
        ]
    }
}

//extension ExchangeCoordinator: ExchangeViewControllerDelegate {
//    func didPress(from: SubmitExchangeToken, to: SubmitExchangeToken, in viewController: ExchangeViewController) {
//
//        let transaction = UnconfirmedTransaction(
//            transferType: .exchange(from: from, to: to),
//            value: from.amount,
//            address: to.token.address,
//            account: session.account,
//            chainID: session.config.chainID,
//            data: Data()
//        )
//
//        let configurator = TransactionConfigurator(
//            session: session,
//            transaction: transaction,
//            gasPrice: .none
//        )
//
//        let controller = ConfirmPaymentViewController(
//            session: session,
//            keystore: keystore,
//            configurator: configurator
//        )
//        controller.delegate = self
//        navigationController.pushViewController(controller, animated: true)
//    }
//}
//
//extension ExchangeCoordinator: ConfirmPaymentViewControllerDelegate {
//    func didCompleted(transaction: SentTransaction, in viewController: ConfirmPaymentViewController) {
//        navigationController.popViewController(animated: true)
//        navigationController.displaySuccess(title: "Exchanged completed. Transaction ID: (\(transaction.id)")
//    }
//}
