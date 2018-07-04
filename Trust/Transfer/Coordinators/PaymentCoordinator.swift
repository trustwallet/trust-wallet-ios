// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustCore

protocol PaymentCoordinatorDelegate: class {
    func didFinish(_ result: ConfirmResult, in coordinator: PaymentCoordinator)
    func didCancel(in coordinator: PaymentCoordinator)
}

class PaymentCoordinator: Coordinator {

    let session: WalletSession
    weak var delegate: PaymentCoordinatorDelegate?

    let flow: PaymentFlow
    var coordinators: [Coordinator] = []
    let navigationController: NavigationController
    let keystore: Keystore
    let storage: TokensDataStore

    lazy var transferType: TransferType = {
        switch self.flow {
        case .send(let type):
            return type
        case .request:
            return .ether(destination: .none)
        }
    }()

    init(
        navigationController: NavigationController = NavigationController(),
        flow: PaymentFlow,
        session: WalletSession,
        keystore: Keystore,
        storage: TokensDataStore
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.flow = flow
        self.keystore = keystore
        self.storage = storage
    }

    func start() {
        switch (flow, session.account.wallet.type) {
        case (.send(let type), .privateKey(let account)),
             (.send(let type), .hd(let account)):
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
        case (.request(let token), _):
            let coordinator = RequestCoordinator(
                navigationController: navigationController,
                session: session,
                token: token
            )
            coordinator.delegate = self
            coordinator.start()
            addCoordinator(coordinator)
        case (.send, .address):
            // This case should be returning an error inCoordinator. Improve this logic into single piece.
            break
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
    func didFinish(_ result: ConfirmResult, in coordinator: SendCoordinator) {
        delegate?.didFinish(result, in: self)
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
