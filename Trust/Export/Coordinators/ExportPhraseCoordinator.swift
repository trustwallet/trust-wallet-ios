// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import TrustCore

protocol ExportPhraseCoordinatorDelegate: class {
    func didCancel(in coordinator: ExportPhraseCoordinator)
}

class ExportPhraseCoordinator: Coordinator {

    let navigationController: NavigationController
    weak var delegate: ExportPhraseCoordinatorDelegate?
    let keystore: Keystore
    let account: Account
    let words: [String]
    var coordinators: [Coordinator] = []
    lazy var rootViewController: PassphraseViewController = {
        let controller = PassphraseViewController(
            account: account,
            words: words
        )
        controller.delegate = self
        controller.title = viewModel.title
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .done,
            target: self,
            action: #selector(dismiss)
        )
        return controller
    }()
    private lazy var viewModel: ExportPhraseViewModel = {
        return .init(keystore: keystore, account: account)
    }()

    init(
        navigationController: NavigationController = NavigationController(),
        keystore: Keystore,
        account: Account,
        words: [String]
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.keystore = keystore
        self.account = account
        self.words = words
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}

extension ExportPhraseCoordinator: PassphraseViewControllerDelegate {
    func didFinish(in controller: PassphraseViewController, with account: Account) {
        delegate?.didCancel(in: self)
    }

    func didPressVerify(in controller: PassphraseViewController, with account: Account, words: [String]) {
        // Missing functionality
    }

    func didPressShare(in controller: PassphraseViewController, sender: UIView, account: Account, words: [String]) {
        let copyValue = words.joined(separator: " ")
        let activityViewController = UIActivityViewController.make(items: [copyValue])
        activityViewController.popoverPresentationController?.sourceView = sender
        activityViewController.popoverPresentationController?.sourceRect = sender.centerRect
        navigationController.present(activityViewController, animated: true)
    }
}
