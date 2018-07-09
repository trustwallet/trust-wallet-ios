// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

final class ExportPrivateKeyCoordinator: RootCoordinator {

    let privateKey: Data
    var coordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return exportViewController
    }
    lazy var exportViewController: ExportPrivateKeyViewConroller = {
        let controller = ExportPrivateKeyViewConroller(viewModel: viewModel)
        controller.navigationItem.title = NSLocalizedString("export.privateKey.navigation.title", value: "Export Private Key", comment: "")
        return controller
    }()
    private lazy var viewModel: ExportPrivateKeyViewModel = {
        return .init(privateKey: privateKey)
    }()

    init(
        privateKey: Data
    ) {
        self.privateKey = privateKey
    }
}
