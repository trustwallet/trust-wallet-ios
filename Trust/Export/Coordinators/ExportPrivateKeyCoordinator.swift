// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

protocol ExportPrivateKeyCoordinatorDelegate: class {
    func didCancel(in coordinator: ExportPrivateKeyCoordinator)
}

class ExportPrivateKeyCoordinator: Coordinator {

    let navigationController: NavigationController
    weak var delegate: ExportPrivateKeyCoordinatorDelegate?
    let privateKey: Data
    var coordinators: [Coordinator] = []
    lazy var exportViewController: ExportPrivateKeyViewConroller = {
        return self.makeExportViewController()
    }()
    private lazy var viewModel: ExportPrivateKeyViewModel = {
        return .init(privateKey: privateKey)
    }()

    init(
        navigationController: NavigationController = NavigationController(),
        privateKey: Data
    ) {
        self.navigationController = navigationController
        self.navigationController.modalPresentationStyle = .formSheet
        self.privateKey = privateKey
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
