// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore
import Result

protocol ConfirmCoordinatorDelegate: class {
    func didCancel(in coordinator: ConfirmCoordinator)
}

class ConfirmCoordinator: Coordinator {

    let navigationController: UINavigationController
    let session: WalletSession
    let account: Account
    let keystore: Keystore
    let configurator: TransactionConfigurator
    var didCompleted: ((Result<ConfirmResult, AnyError>) -> Void)?
    let type: ConfirmType

    var coordinators: [Coordinator] = []
    weak var delegate: ConfirmCoordinatorDelegate?

    init(
        navigationController: UINavigationController,
        session: WalletSession,
        configurator: TransactionConfigurator,
        keystore: Keystore,
        account: Account,
        type: ConfirmType
    ) {
        self.navigationController = navigationController
        self.session = session
        self.configurator = configurator
        self.keystore = keystore
        self.account = account
        self.type = type
    }

    func start() {
        let controller = ConfirmPaymentViewController(
            session: session,
            keystore: keystore,
            configurator: configurator,
            confirmType: type
        )
        controller.didCompleted = { result in
            switch result {
            case .success(let data):
                self.didCompleted?(.success(data))
            case .failure(let error):
                self.navigationController.displayError(error: error)
            }
        }
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))

        navigationController.viewControllers = [controller]
    }

    @objc func dismiss() {
        didCompleted?(.failure(AnyError(DAppError.cancelled)))
        delegate?.didCancel(in: self)
    }
}
