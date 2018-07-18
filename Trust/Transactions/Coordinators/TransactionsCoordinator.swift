// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

class TransactionsCoordinator: RootCoordinator {

    let session: WalletSession
    let storage: TransactionsStorage
    let network: NetworkProtocol
    var coordinators: [Coordinator] = []

    var rootViewController: UIViewController {
        return transactionViewController
    }

    lazy var viewModel: TransactionsViewModel = {
        return TransactionsViewModel(
            network: network,
            storage: storage,
            session: session
        )
    }()

    lazy var transactionViewController: TransactionsViewController = {
        let controller = TransactionsViewController(
            session: session,
            viewModel: viewModel
        )
        return controller
    }()

    init(
        session: WalletSession,
        storage: TransactionsStorage,
        network: NetworkProtocol
    ) {
        self.session = session
        self.storage = storage
        self.network = network
    }
}
