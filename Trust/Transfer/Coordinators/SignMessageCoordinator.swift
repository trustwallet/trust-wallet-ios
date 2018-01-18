// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore
import CryptoSwift

protocol SignMessageCoordinatorDelegate: class {
    func didSignMesage(message: String, in coordinator: SignMessageCoordinator)
    func didError(error: Error, in coordinator: SignMessageCoordinator)
    func didCancel(in coordinator: SignMessageCoordinator)
}

class SignMessageCoordinator: Coordinator {

    var coordinators: [Coordinator] = []

    let navigationController: UINavigationController
    let keystore: Keystore
    let account: Account

    weak var delegate: SignMessageCoordinatorDelegate?

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
            self.handleSignedMessage(message: message)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", value: "Cancel", comment: ""), style: .cancel) { [weak self] _ in
            guard let `self` = self else { return }
            self.delegate?.didCancel(in: self)
        }
        alertController.addAction(signAction)
        alertController.addAction(cancelAction)
        return alertController
    }

    private func handleSignedMessage(message: String) {
        let result = self.keystore.signMessage(message: message, account: self.account)
        switch result {
        case .success(let data):
            delegate?.didSignMesage(message: data.toHexString(), in: self)
        case .failure(let error):
            delegate?.didError(error: error, in: self)
        }
    }
}
