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
    let transfer: Transfer
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
            transfer: transfer
        )
        controller.navigationItem.backBarButtonItem = nil
        controller.hidesBottomBarWhenPushed = true
        switch transfer.type {
        case .ether(let destination):
            controller.addressRow?.value = destination?.description
            controller.addressRow?.cell.row.updateCell()
        case .token, .dapp, .nft: break
        }
        controller.delegate = self
        return controller
    }()

    init(
        transfer:  Transfer,
        navigationController: NavigationController = NavigationController(),
        session: WalletSession,
        keystore: Keystore,
        storage: TokensDataStore,
        account: Account
    ) {
        self.transfer = transfer
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.account = account
        self.keystore = keystore
        self.storage = storage
    }
}

extension SendCoordinator: SendViewControllerDelegate {
    func didPressConfirm(transaction: UnconfirmedTransaction, transfer: Transfer, in viewController: SendViewController) {
        let configurator = TransactionConfigurator(
            session: session,
            account: account,
            transaction: transaction,
            server: RPCServer(chainID: 1) //Refactor
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
