// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result

protocol ExportCoordinatorDelegate: class {
    func didFinish(in coordinator: ExportCoordinator)
    func didCancel(in coordinator: ExportCoordinator)
}

class ExportCoordinator: Coordinator {

    let presenterViewController: UIViewController
    weak var delegate: ExportCoordinatorDelegate?
    let keystore = EtherKeystore()
    var coordinators: [Coordinator] = []
    lazy var accountViewController: AccountsViewController = {
        let controller = AccountsViewController()
        controller.headerTitle = "Select Account to Export"
        controller.delegate = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        return controller
    }()

    lazy var rootNavigationController: UINavigationController = {
        return NavigationController(rootViewController: self.accountViewController)
    }()

    init(presenterViewController: UIViewController) {
        self.presenterViewController = presenterViewController
    }

    func start() {
        presenterViewController.present(rootNavigationController, animated: true, completion: nil)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    func finish() {
        delegate?.didFinish(in: self)
    }

    func presentActivityViewController(for account: Account, password: String, newPassword: String, completion: @escaping () -> Void) {
        let result = keystore.export(account: account, password: password, newPassword: newPassword)

        switch result {
        case .success(let value):
            let activityViewController = UIActivityViewController(
                activityItems: [value],
                applicationActivities: nil
            )
            activityViewController.completionWithItemsHandler = { result in
                completion()
            }
            activityViewController.popoverPresentationController?.sourceView = self.accountViewController.view
            rootNavigationController.present(activityViewController, animated: true, completion: nil)
        case .failure(let error):
            rootNavigationController.displayError(error: error)
        }
    }

    func presentShareActivity(for account: Account, password: String, newPassword: String) {
        self.presentActivityViewController(for: account, password: password, newPassword: newPassword) {
            self.finish()
        }
    }
}

extension ExportCoordinator: AccountsViewControllerDelegate {
    func didSelectAccount(account: Account, in viewController: AccountsViewController) {

        if let currentPassword = keystore.getPassword(for: account) {
            let verifyController = UIAlertController.askPassword(
                title: NSLocalizedString("export.enterNewPasswordWallet", value: "Enter new password to export your wallet", comment: "")
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
            rootNavigationController.present(verifyController, animated: true, completion: nil)
        } else {
            //FIXME: remove later. for old version, when password were missing in the keychain
            let verifyController = UIAlertController.askPassword(
                title: NSLocalizedString("export.enterCurrentPasswordWallet", value: "Enter current password to export your wallet", comment: "")
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
            rootNavigationController.present(verifyController, animated: true, completion: nil)
        }
    }

    func didDeleteAccount(account: Account, in viewController: AccountsViewController) {

    }
}
