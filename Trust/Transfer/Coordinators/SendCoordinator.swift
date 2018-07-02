// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt
import TrustCore
import TrustKeystore

protocol SendCoordinatorDelegate: class {
    func didFinish(_ result: ConfirmResult, in coordinator: SendCoordinator)
    func didCancel(in coordinator: SendCoordinator)
}

class SendCoordinator: Coordinator {

    let transferType: TransferType
    let session: WalletSession
    let account: Account
    let navigationController: NavigationController
    let keystore: Keystore
    let storage: TokensDataStore
    var coordinators: [Coordinator] = []
    weak var delegate: SendCoordinatorDelegate?
    lazy var sendViewController: SendViewController = {
        return self.makeSendViewController()
    }()

    init(
        transferType: TransferType,
        navigationController: NavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore,
        storage: TokensDataStore,
        account: Account
    ) {
        self.transferType = transferType
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.account = account
        self.keystore = keystore
        self.storage = storage
    }

    func start() {
        navigationController.viewControllers = [sendViewController]
    }

    func makeSendViewController() -> SendViewController {
        let controller = SendViewController(
            session: session,
            storage: storage,
            account: account,
            transferType: transferType
        )
        controller.navigationItem.titleView = BalanceTitleView.make(from: self.session, transferType)
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: R.string.localizable.next(),
            style: .done,
            target: controller,
            action: #selector(SendViewController.send)
        )
        switch transferType {
        case .ether(let destination):
            controller.addressRow?.value = destination?.description
            controller.addressRow?.cell.row.updateCell()
        case .token, .dapp, .nft: break
        }
        controller.delegate = self
        return controller
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}

extension SendCoordinator: SendViewControllerDelegate {
    func didPressConfirm(transaction: UnconfirmedTransaction, transferType: TransferType, in viewController: SendViewController) {
        let configurator = TransactionConfigurator(
            session: session,
            account: account,
            transaction: transaction
        )

//        let coordinator = ConfirmCoordinator(
//            navigationController: navigationController,
//            session: session,
//            configurator: configurator,
//            keystore: keystore,
//            account: account,
//            type: .signThenSend
//        )
//        coordinator.start()
//        addCoordinator(coordinator)

        let controller = ConfirmPaymentViewController(
            session: session,
            keystore: keystore,
            configurator: configurator,
            confirmType: .signThenSend
        )
        controller.didCompleted = { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let type):
                self.delegate?.didFinish(type, in: self)
            case .failure(let error):
                self.navigationController.displayError(error: error)
            }
        }
        navigationController.pushViewController(controller, animated: true)
    }
}
