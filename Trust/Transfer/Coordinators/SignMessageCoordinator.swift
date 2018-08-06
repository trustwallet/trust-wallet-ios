// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustCore
import TrustKeystore
import Result

enum SignMesageType {
    case message(Data)
    case personalMessage(Data)
    case typedMessage([EthTypedData])
}

protocol SignMessageCoordinatorDelegate: class {
    func didCancel(in coordinator: SignMessageCoordinator)
}

final class SignMessageCoordinator: Coordinator {

    var coordinators: [Coordinator] = []

    let navigationController: NavigationController
    let keystore: Keystore
    let account: Account

    weak var delegate: SignMessageCoordinatorDelegate?
    var didComplete: ((Result<Data, AnyError>) -> Void)?

    init(
        navigationController: NavigationController,
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
            title: NSLocalizedString("Confirm signing this message:", value: "Confirm signing this message:", comment: ""),
            message: message(for: type),
            preferredStyle: .alert
        )
        let signAction = UIAlertAction(
            title: R.string.localizable.oK(),
            style: .default
        ) { [weak self] _ in
            guard let `self` = self else { return }
            self.handleSignedMessage(with: type)
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { [weak self] _ in
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
        case .message(let data),
             .personalMessage(let data):
                guard let message = String(data: data, encoding: .utf8) else {
                    return data.hexEncoded
                }
                return message
        case .typedMessage(let (typedData)):
                let string = typedData.map {
                    return "\($0.name) : \($0.value.string)"
                }.joined(separator: "\n")
                return string
        }
    }

    func isMessage(data: Data) -> Bool {
        guard let _ = String(data: data, encoding: .utf8) else { return false }
        return true
    }

    private func handleSignedMessage(with type: SignMesageType) {
        let result: Result<Data, KeystoreError>
        switch type {
        case .message(let data):
            // FIXME. If hash just sign it, otherwise call sign message
            if isMessage(data: data) {
                result = keystore.signMessage(data, for: account)
            } else {
                result = keystore.signHash(data, for: account)
            }
        case .personalMessage(let data):
            result = keystore.signPersonalMessage(data, for: account)
        case .typedMessage(let typedData):
            if typedData.isEmpty {
                result = .failure(KeystoreError.failedToSignMessage)
            } else {
                result = keystore.signTypedMessage(typedData, for: account)
            }
        }
        switch result {
        case .success(let data):
            didComplete?(.success(data))
        case .failure(let error):
            didComplete?(.failure(AnyError(error)))
        }
    }
}
