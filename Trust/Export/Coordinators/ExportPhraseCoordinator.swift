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
    var coordinators: [Coordinator] = []
    lazy var rootViewController: PassphraseViewController = {
        let controller = PassphraseViewController(
            words: viewModel.words
        )
        controller.title = viewModel.title
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
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
        account: Account
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.keystore = keystore
        self.account = account
    }

    func start() {
        navigationController.viewControllers = [rootViewController]
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}
