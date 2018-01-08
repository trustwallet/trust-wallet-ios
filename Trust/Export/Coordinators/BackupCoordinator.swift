// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result
import TrustKeystore

protocol BackupCoordinatorDelegate: class {
    func didCancel(coordinator: BackupCoordinator)
    func didFinish(account: Account, in coordinator: BackupCoordinator)
}

class BackupCoordinator: Coordinator {

    let navigationController: UINavigationController
    weak var delegate: BackupCoordinatorDelegate?
    let keystore: Keystore
    let account: Account
    var coordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController,
        keystore: Keystore,
        account: Account
    ) {
        self.navigationController = navigationController
        self.keystore = keystore
        self.account = account
    }

    func start() {
        export(for: account)
    }

    func finish(completed: Bool) {
        if completed {
            delegate?.didFinish(account: account, in: self)
        } else {
            delegate?.didCancel(coordinator: self)
        }
    }

    func presentActivityViewController(for account: Account, password: String, newPassword: String, completion: @escaping (Bool) -> Void) {
        let result = keystore.export(account: account, password: password, newPassword: newPassword)

        navigationController.displayLoading(
            text: NSLocalizedString("export.presentBackupOptions.label.title", value: "Preparing backup options...", comment: "")
        )

        switch result {
        case .success(let value):
            let activityViewController = UIActivityViewController(
                activityItems: [value],
                applicationActivities: nil
            )
            activityViewController.completionWithItemsHandler = { _, result, _, _ in
                completion(result)
            }
            activityViewController.popoverPresentationController?.sourceView = navigationController.view
            activityViewController.popoverPresentationController?.sourceRect = navigationController.view.centerRect
            navigationController.present(activityViewController, animated: true) { [unowned self] in
                self.navigationController.hideLoading()
            }
        case .failure(let error):
            navigationController.hideLoading()
            navigationController.displayError(error: error)
        }
    }

    func presentShareActivity(for account: Account, password: String, newPassword: String) {
        self.presentActivityViewController(for: account, password: password, newPassword: newPassword) { completed in
            self.finish(completed: completed)
        }
    }

    func export(for account: Account) {
        if let currentPassword = keystore.getPassword(for: account) {
            let verifyController = UIAlertController.askPassword(
                title: NSLocalizedString("export.enterPassword.textField.title", value: "Enter password to encrypt your wallet", comment: "")
            ) { result in
                switch result {
                case .success(let newPassword):
                    self.presentShareActivity(
                        for: account,
                        password: currentPassword,
                        newPassword: newPassword
                    )
                case .failure: break
                }
            }
            navigationController.present(verifyController, animated: true, completion: nil)
        } else {
            //FIXME: remove later. for old version, when password were missing in the keychain
            let verifyController = UIAlertController.askPassword(
                title: NSLocalizedString("export.enterCurrentPassword.textField.title", value: "Enter current password to export your wallet", comment: "")
            ) { result in
                switch result {
                case .success(let newPassword):
                    self.presentShareActivity(
                        for: account,
                        password: newPassword,
                        newPassword: newPassword
                    )
                case .failure: break
                }
            }
            navigationController.present(verifyController, animated: true, completion: nil)
        }
    }
}
