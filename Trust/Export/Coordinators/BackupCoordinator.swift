// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Result
import TrustKeystore
import Result

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

    func finish(result: Result<Bool, AnyError>) {
        switch result {
        case .success:
            delegate?.didFinish(account: account, in: self)
        case .failure:
            delegate?.didCancel(coordinator: self)
        }
    }

    func presentActivityViewController(for account: Account, password: String, newPassword: String, completion: @escaping (Result<Bool, AnyError>) -> Void) {
        navigationController.displayLoading(
            text: NSLocalizedString("export.presentBackupOptions.label.title", value: "Preparing backup options...", comment: "")
        )
        keystore.export(account: account, password: password, newPassword: newPassword) { [weak self] result in
            guard let `self` = self else { return }
            self.handleExport(result: result, completion: completion)
        }
    }

    private func handleExport(result: (Result<String, KeystoreError>), completion: @escaping (Result<Bool, AnyError>) -> Void) {
        switch result {
        case .success(let value):
            let url = URL(fileURLWithPath: NSTemporaryDirectory().appending("trust_backup_\(account.address.description.prefix(12)).json"))
            do {
                try value.data(using: .utf8)!.write(to: url)
            } catch {
                return completion(.failure(AnyError(error)))
            }

            let activityViewController = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil
            )
            activityViewController.completionWithItemsHandler = { _, result, _, error in
                do { try FileManager.default.removeItem(at: url)
            } catch { }
                completion(.success(result))
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
        self.presentActivityViewController(for: account, password: password, newPassword: newPassword) { result in
            self.finish(result: result)
        }
    }

    func export(for account: Account) {
        let coordinator = EnterPasswordCoordinator(account: account)
        coordinator.delegate = self
        coordinator.start()
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
        addCoordinator(coordinator)
    }
}

extension BackupCoordinator: EnterPasswordCoordinatorDelegate {
    func didCancel(in coordinator: EnterPasswordCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didEnterPassword(password: String, account: Account, in coordinator: EnterPasswordCoordinator) {
        coordinator.navigationController.dismiss(animated: true) { [unowned self] in
            if let currentPassword = self.keystore.getPassword(for: account) {
                self.presentShareActivity(for: account, password: currentPassword, newPassword: password)
            } else {
                self.presentShareActivity(for: account, password: password, newPassword: password)
            }
        }
        removeCoordinator(coordinator)
    }
}
