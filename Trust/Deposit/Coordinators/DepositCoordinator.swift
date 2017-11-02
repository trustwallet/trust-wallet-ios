// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class DepositCoordinator: Coordinator {

    let navigationController: UINavigationController
    let account: Account
    var coordinators: [Coordinator] = []

    init(
        navigationController: UINavigationController,
        account: Account
    ) {
        self.navigationController = navigationController
        self.account = account
    }

    func start() {
        let widget = CoinbaseBuyWidget(
            address: account.address.address
        )
        navigationController.openURL(widget.url)
    }
}
