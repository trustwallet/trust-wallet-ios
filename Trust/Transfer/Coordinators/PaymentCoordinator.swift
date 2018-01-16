// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

protocol PaymentCoordinatorDelegate: class {
    func didCreatePendingTransaction(transaction: SentTransaction, in coordinator: PaymentCoordinator)
    func didCancel(in coordinator: PaymentCoordinator)
}

class PaymentCoordinator: Coordinator {

    let session: WalletSession
    weak var delegate: PaymentCoordinatorDelegate?

    let flow: PaymentFlow
    var coordinators: [Coordinator] = []
    let navigationController: UINavigationController
    let keystore: Keystore
    let storage: TokensDataStore
    let account: Account

    lazy var transferType: TransferType = {
        switch self.flow {
        case .send(let type):
            return type
        case .request:
            return .ether(destination: .none)
        }
    }()

    init(
        navigationController: UINavigationController = UINavigationController(),
        flow: PaymentFlow,
        session: WalletSession,
        keystore: Keystore,
        storage: TokensDataStore,
        account: Account
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.account = account
        self.flow = flow
        self.keystore = keystore
        self.storage = storage
    }

    func start() {
        switch flow {
        case .send(let type):
            let coordinator = SendCoordinator(
                transferType: type,
                navigationController: navigationController,
                session: session,
                keystore: keystore,
                storage: storage,
                account: account
            )
            coordinator.delegate = self
            coordinator.start()
            addCoordinator(coordinator)
        case .request:
            let coordinator = RequestCoordinator(
                navigationController: navigationController,
                session: session
            )
            coordinator.delegate = self
            coordinator.start()
            addCoordinator(coordinator)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func cancel() {
        delegate?.didCancel(in: self)
    }
}

extension PaymentCoordinator: SendCoordinatorDelegate {
    func didCreatePendingTransaction(_ transaction: SentTransaction, in coordinator: SendCoordinator) {
        delegate?.didCreatePendingTransaction(transaction: transaction, in: self)
    }

    func didCancel(in coordinator: SendCoordinator) {
        removeCoordinator(coordinator)
        cancel()
    }
}

extension PaymentCoordinator: RequestCoordinatorDelegate {
    func didCancel(in coordinator: RequestCoordinator) {
        removeCoordinator(coordinator)
        cancel()
    }
}
