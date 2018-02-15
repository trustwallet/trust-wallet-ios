// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore
import CryptoSwift
import Result

enum SignMesageType {
    case message(Data)
    case personalMessage(Data)
}

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

    func start(with type: SignMesageType) {
        let alertController = makeAlertController(with: type)
        navigationController.present(alertController, animated: true, completion: nil)
    }

    private func makeAlertController(with type: SignMesageType) -> UIAlertController {
        let alertController = UIAlertController(
            title: NSLocalizedString("", value: "Confirm signing this message:", comment: ""),
            message: message(for: type),
            preferredStyle: .alert
        )
        let signAction = UIAlertAction(
            title: NSLocalizedString("OK", value: "OK", comment: ""),
            style: .default
        ) { [weak self] _ in
            guard let `self` = self else { return }
            self.handleSignedMessage(with: type)
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

    func message(for type: SignMesageType) -> String {
        switch type {
        case .message(let data):
            return data.hexEncoded
        case .personalMessage(let data):
            return String(data: data, encoding: .utf8)!
        }
    }

    private func handleSignedMessage(with type: SignMesageType) {
        let result: Result<Data, KeystoreError>
        switch type {
        case .message(let data):
            result = keystore.signMessage(data, for: account)
        case .personalMessage(let data):
            result = keystore.signPersonalMessage(data, for: account)
        }
        switch result {
        case .success(let data):
            didComplete?(.success(data))
        case .failure(let error):
            didComplete?(.failure(AnyError(error)))
        }
    }
}
