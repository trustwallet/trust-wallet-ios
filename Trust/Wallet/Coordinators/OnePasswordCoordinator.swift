// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import OnePasswordExtension
import Result
import TrustKeystore

class OnePasswordCoordinator {

    let keystore: Keystore

    init(keystore: Keystore) {
        self.keystore = keystore
    }

    func createWallet(in viewController: UIViewController, completion: @escaping (Result<Account, AnyError>) -> Void) {

        let newPasssword = PasswordGenerator.generateRandom()
        let account = keystore.createAccout(password: newPasssword)
        let keystoreString: String = {
            let value = keystore.export(account: account, password: newPasssword, newPassword: newPasssword)
            switch value {
            case .success(let string):
                return string
            case .failure: return ""
            }
        }()

        let formattedPassword = OnePasswordConverter.toPassword(password: newPasssword, keystore: keystoreString)

        OnePasswordExtension().storeLogin(
            forURLString: OnePasswordConfig.url,
            loginDetails: [
                AppExtensionUsernameKey: account.address.description,
                AppExtensionPasswordKey: formattedPassword,
                AppExtensionNotesKey: "Ethereum wallet has been stored here. Format: password-trust-keystore. -trust- - is a divider between password and keystore",
            ],
            passwordGenerationOptions: [:],
            for: viewController,
            sender: nil
        ) { results, error in
            let results = results ?? [:]
            if error != nil {
                let _ = self.keystore.delete(account: account)
            } else {
                let updatedPassword = results[AppExtensionPasswordKey] as? String ?? ""
                let result = OnePasswordConverter.fromPassword(password: updatedPassword)
                switch result {
                case .success(let password, _):
                    if password == newPasssword {
                        completion(.success(account))
                    } else {
                        let result = self.keystore.updateAccount(account: account, password: password, newPassword: updatedPassword)
                        switch result {
                        case .success:
                            completion(.success(account))
                        case .failure(let error):
                            completion(.failure(AnyError(error)))
                        }
                    }
                case .failure(let error):
                    completion(.failure(AnyError(error)))
                }
            }
        }
    }

    func importWallet(in viewController: UIViewController, completion: @escaping (Result<(password: String, keystore: String), AnyError>) -> Void) {
        OnePasswordExtension().findLogin(
            forURLString: OnePasswordConfig.url,
            for: viewController,
            sender: nil
        ) { results, error in
            if let error = error {
                return completion(.failure(AnyError(error)))
            }
            guard let password = results?[AppExtensionPasswordKey] as? String else { return }

            let result = OnePasswordConverter.fromPassword(password: password)

            switch result {
            case .success(let password, let keystore):
                completion(.success((password: password, keystore: keystore)))
            case .failure(let error):
                completion(.failure(AnyError(error)))
            }
        }
    }
}
