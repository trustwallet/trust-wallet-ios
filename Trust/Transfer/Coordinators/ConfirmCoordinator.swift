// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustCore
import TrustKeystore
import Result

protocol ConfirmCoordinatorDelegate: class {
    func didCancel(in coordinator: ConfirmCoordinator)
}

final class ConfirmCoordinator: RootCoordinator {
    let navigationController: NavigationController
    let session: WalletSession
    let account: Account
    let keystore: Keystore
    let configurator: TransactionConfigurator
    var didCompleted: ((Result<ConfirmResult, AnyError>) -> Void)?
    let type: ConfirmType
    let server: RPCServer

    var coordinators: [Coordinator] = []
    weak var delegate: ConfirmCoordinatorDelegate?

    var rootViewController: UIViewController {
        return controller
    }

    private lazy var controller: ConfirmPaymentViewController = {
        return ConfirmPaymentViewController(
            session: session,
            keystore: keystore,
            configurator: configurator,
            confirmType: type,
            server: server
        )
    }()

    init(
        navigationController: NavigationController = NavigationController(),
        session: WalletSession,
        configurator: TransactionConfigurator,
        keystore: Keystore,
        account: Account,
        type: ConfirmType,
        server: RPCServer
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.session = session
        self.configurator = configurator
        self.keystore = keystore
        self.account = account
        self.type = type
        self.server = server

        controller.didCompleted = { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let data):
                self.didCompleted?(.success(data))
            case .failure(let error):
                self.didCompleted?(.failure(error))
            }
        }
    }

    func start() {
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        navigationController.viewControllers = [controller]
    }

    @objc func dismiss() {
        didCompleted?(.failure(AnyError(DAppError.cancelled)))
        delegate?.didCancel(in: self)
    }
}
