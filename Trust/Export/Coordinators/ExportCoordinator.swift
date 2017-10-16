// Copyright SIX DAY LLC. All rights reserved.

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

    func presentActivityViewController(for account: Account, password: String, completionHandler: @escaping () -> Void) {
        let result = keystore.export(account: account, password: password)

        switch result {
        case .success(let value):
            let activityViewController = UIActivityViewController(
                activityItems: [value],
                applicationActivities: nil
            )
            activityViewController.completionWithItemsHandler = { result in
                completionHandler()
            }
            activityViewController.popoverPresentationController?.sourceView = self.accountViewController.view
            rootNavigationController.present(activityViewController, animated: true, completion: nil)
        case .failure(let error):
            rootNavigationController.displayError(error: error)
        }
    }

    func presentShareActivity(for account: Account, password: String) {
        self.presentActivityViewController(for: account, password: password, completionHandler: {
            self.finish()
        })
    }
}

extension ExportCoordinator: AccountsViewControllerDelegate {
    func didSelectAccount(account: Account, in viewController: AccountsViewController) {

        if let password = keystore.getPassword(for: account) {
            self.presentShareActivity(for: account, password: password)
        } else {
            //TODO: Remove this part in future versions.
            let verifyController = UIAlertController.askPassword(title: "Enter password to your wallet") { result in
                switch result {
                case .success(let password):
                    self.presentShareActivity(for: account, password: password)
                case .failure: break
                }
            }
            rootNavigationController.present(verifyController, animated: true, completion: nil)
        }
    }

    func didDeleteAccount(account: Account, in viewController: AccountsViewController) {

    }
}
