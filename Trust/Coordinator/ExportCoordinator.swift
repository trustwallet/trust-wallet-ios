// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit
import Result

protocol ExportCoordinatorDelegate: class {
    func didFinish(in coordinator: ExportCoordinator)
    func didCancel(in coordinator: ExportCoordinator)
}

class ExportCoordinator {

    let navigationController: UIViewController
    weak var delegate: ExportCoordinatorDelegate?
    let keystore = EtherKeystore()

    lazy var rootNavigationController: UINavigationController = {
        let controller = AccountsViewController()
        controller.headerTitle = "Select Account to Export"
        controller.delegate = self
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(dismiss))
        return NavigationController(rootViewController: controller)
    }()

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        navigationController.present(rootNavigationController, animated: true, completion: nil)
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }

    func finish() {
        delegate?.didFinish(in: self)
    }

    func presentActivityViewController(for account: Account, newPassword: String, completionHandler: @escaping () -> Void) {
        let result = keystore.export(account: account, newPassword: newPassword)

        switch result {
        case .success(let value):
            let activityViewController = UIActivityViewController(
                activityItems: [value],
                applicationActivities: nil
            )
            activityViewController.completionWithItemsHandler = { result in
                completionHandler()
            }
            rootNavigationController.present(activityViewController, animated: true, completion: nil)
        case .failure(let error):
            rootNavigationController.displayError(error: error)
        }
    }
}

extension ExportCoordinator: AccountsViewControllerDelegate {
    func didSelectAccount(account: Account, in viewController: AccountsViewController) {
        let verifyController = UIAlertController.askPassword(title: "Enter your new password") { result in
            switch result {
            case .success(let newPassword):
                self.presentActivityViewController(for: account, newPassword: newPassword, completionHandler: {
                    self.finish()
                })
            case .failure: break
            }
        }
        rootNavigationController.present(verifyController, animated: true, completion: nil)
    }

    func didDeleteAccount(account: Account, in viewController: AccountsViewController) {

    }
}
