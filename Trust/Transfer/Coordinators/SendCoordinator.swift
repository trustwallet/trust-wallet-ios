// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import BigInt
import TrustCore
import TrustKeystore
import Result

protocol SendCoordinatorDelegate: class {
    func didFinish(_ result: Result<ConfirmResult, AnyError>, in coordinator: SendCoordinator)
}

final class SendCoordinator: RootCoordinator {
    let transferType: TransferType
    let session: WalletSession
    let account: Account
    let navigationController: NavigationController
    let keystore: Keystore
    let storage: TokensDataStore
    var coordinators: [Coordinator] = []
    weak var delegate: SendCoordinatorDelegate?
    var rootViewController: UIViewController {
        return controller
    }

    private lazy var controller: SendViewController = {
        let controller = SendViewController(
            session: session,
            storage: storage,
            account: account,
            transferType: transferType
        )
        controller.navigationItem.backBarButtonItem = nil
        controller.navigationItem.titleView = BalanceTitleView.make(from: self.session, transferType)
        controller.hidesBottomBarWhenPushed = true
        switch transferType {
        case .ether(let destination):
            controller.addressRow?.value = destination?.description
            controller.addressRow?.cell.row.updateCell()
        case .token, .dapp, .nft: break
        }
        controller.delegate = self
        return controller
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
}

extension SendCoordinator: SendViewControllerDelegate {
    func didPressConfirm(transaction: UnconfirmedTransaction, transferType: TransferType, in viewController: SendViewController) {
        let configurator = TransactionConfigurator(
            session: session,
            account: account,
            transaction: transaction
        )

        let coordinator = ConfirmCoordinator(
            navigationController: navigationController,
            session: session,
            configurator: configurator,
            keystore: keystore,
            account: account,
            type: .signThenSend
        )
        coordinator.didCompleted = { [weak self] result in
            guard let `self` = self else { return }
            self.delegate?.didFinish(result, in: self)
        }
        addCoordinator(coordinator)
        navigationController.pushCoordinator(coordinator: coordinator, animated: true)
    }
}
