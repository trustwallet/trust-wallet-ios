// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

protocol ExportPrivateKeyCoordinatorDelegate: class {
    func didCancel(in coordinator: ExportPrivateKeyCoordinator)
}

class ExportPrivateKeyCoordinator: Coordinator {

    let navigationController: UINavigationController
    weak var delegate: ExportPrivateKeyCoordinatorDelegate?
    let keystore: Keystore
    let account: Account
    var coordinators: [Coordinator] = []
    lazy var exportViewController: ExportPrivateKeyViewConroller = {
        return self.makeExportViewController()
    }()
    private lazy var viewModel: ExportPrivateKeyViewModel = {
        return .init(keystore: keystore,
                     account: account)
    }()

    init(
        navigationController: UINavigationController = NavigationController(),
        keystore: Keystore,
        account: Account
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.keystore = keystore
        self.account = account
    }

    func start() {
        navigationController.viewControllers = [exportViewController]
    }

    func makeExportViewController() -> ExportPrivateKeyViewConroller {
        let controller = ExportPrivateKeyViewConroller(viewModel: viewModel)
        controller.navigationItem.title = NSLocalizedString("export.privateKey.navigation.title", value: "Export Private Key", comment: "")
        controller.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismiss))
        return controller
    }

    @objc func dismiss() {
        delegate?.didCancel(in: self)
    }
}
