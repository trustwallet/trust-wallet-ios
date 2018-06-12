// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustCore
import TrustKeystore
import Result

protocol ConfirmCoordinatorDelegate: class {
    func didCancel(in coordinator: ConfirmCoordinator)
}

class ConfirmCoordinator: Coordinator {
    let navigationController: NavigationController
    let session: WalletSession
    let account: Account
    let keystore: Keystore
    let configurator: TransactionConfigurator
    var didCompleted: ((Result<ConfirmResult, AnyError>) -> Void)?
    let type: ConfirmType

    var coordinators: [Coordinator] = []
    weak var delegate: ConfirmCoordinatorDelegate?

    init(
        navigationController: NavigationController,
        session: WalletSession,
        configurator: TransactionConfigurator,
        keystore: Keystore,
        account: Account,
        type: ConfirmType
    ) {
        self.navigationController = navigationController
        //self.navigationController.modalPresentationStyle = .custom
        self.navigationController.modalPresentationStyle = .formSheet
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
        //navigationController.transitioningDelegate = controller as UIViewControllerTransitioningDelegate
        controller.didCompleted = { [weak self] result in
            switch result {
            case .success(let data):
                self?.didCompleted?(.success(data))
            case .failure(let error):
                self?.navigationController.displayError(error: error)
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

extension ConfirmPaymentViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
