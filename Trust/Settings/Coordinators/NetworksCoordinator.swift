// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol NetworksCoordinatorDelegate: class {
    //TODO
}

class NetworksCoordinator: Coordinator {
    let navigationController: UINavigationController
    let rpcStore: RPCStore
    //TODO: Get existing networks in here too
    var coordinators: [Coordinator] = []

    lazy var networksViewController: NetworksViewController = {
        let controller = NetworksViewController()
        controller.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNetwork))
        controller.delegate = self
        return controller
    }()

    weak var delegate: NetworksCoordinatorDelegate?

    init(
        navigationController: UINavigationController,
        rpcStore: RPCStore
    ) {
        self.navigationController = navigationController
        self.rpcStore = rpcStore
    }

    func start() {
        navigationController.pushViewController(networksViewController, animated: false)
    }

    @objc func addNetwork() {
        showAddNetwork()
    }
    
    func showAddNetwork() {
        
    }
}

extension NetworksCoordinator: NetworksViewControllerDelegate {
    //TODO
}
