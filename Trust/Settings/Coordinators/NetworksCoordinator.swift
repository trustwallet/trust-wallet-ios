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
        let controller = NetworksViewController(networksStore: rpcStore)
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

    func showAddNetwork() {
        let coordinator = AddCustomNetworkCoordinator(navigationController: NavigationController(), rpcStore: rpcStore)
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
        navigationController.present(coordinator.navigationController, animated: true, completion: nil)
    }
}

extension NetworksCoordinator: AddCustomNetworkCoordinatorDelegate {
    func didAddNetwork(network: CustomRPC, in coordinator: AddCustomNetworkCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
        rpcStore.add(endpoints: [network])
    }

    func didCancel(in coordinator: AddCustomNetworkCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension NetworksCoordinator: NetworksViewControllerDelegate {
    func didClickAddNetwork() {
        showAddNetwork()
    }
}
