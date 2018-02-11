// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore
import CryptoSwift
import Result

protocol SignMessageCoordinatorDelegate: class {
    func didCancel(in coordinator: SignMessageCoordinator)
}

class SignMessageCoordinator: Coordinator {

    var coordinators: [Coordinator] = []

    let navigationController: UINavigationController
    let keystore: Keystore
    let account: Account

    weak var delegate: SignMessageCoordinatorDelegate?
    var didComplete: ((Result<Data, AnyError>) -> Void)?

    init(
        navigationController: UINavigationController,
        keystore: Keystore,
        account: Account
    ) {
        self.navigationController = navigationController
        self.keystore = keystore
        self.account = account
    }

    func start(with message: String) {

        let alertController = makeAlertController(message: message)
        navigationController.present(alertController, animated: true, completion: nil)
    }

    private func makeAlertController(message: String) -> UIAlertController {
        let alertController = UIAlertController(
            title: NSLocalizedString("", value: "Confirm signing this message:", comment: ""),
            message: message,
            preferredStyle: .alert
        )
        let signAction = UIAlertAction(
            title: NSLocalizedString("OK", value: "OK", comment: ""),
            style: .default
        ) { [weak self] _ in
            guard let `self` = self else { return }
            self.handleSignedPersonalMessage(message: message)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", value: "Cancel", comment: ""), style: .cancel) { [weak self] _ in
            guard let `self` = self else { return }
            self.didComplete?(.failure(AnyError(DAppError.cancelled)))
            self.delegate?.didCancel(in: self)
        }
        alertController.addAction(signAction)
        alertController.addAction(cancelAction)
        return alertController
    }

    private func handleSignedPersonalMessage(message: String) {
        let result = self.keystore.signPersonalMessage(message, for: self.account)
        switch result {
        case .success(let data):
            didComplete?(.success(data))
        case .failure(let error):
            didComplete?(.failure(AnyError(error)))
        }
    }
}
