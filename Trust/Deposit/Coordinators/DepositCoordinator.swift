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
        showAlertSheet()
    }

    func showAlertSheet() {
        let alertController = UIAlertController(
            title: nil,
            message: NSLocalizedString("deposit.alertSheetMessage", value: "How would you like to deposit?", comment: ""),
            preferredStyle: .actionSheet
        )
        let coinbaseAction = UIAlertAction(title: NSLocalizedString("deposit.coinbaseOption", value: "via Coinbase", comment: ""), style: .default) { _ in
            self.showCoinbase()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("generic.cancel", value: "Cancel", comment: ""), style: .cancel) { _ in }

        alertController.addAction(coinbaseAction)
        alertController.addAction(cancelAction)
        navigationController.present(alertController, animated: true, completion: nil)
    }

    func showCoinbase() {
        let widget = CoinbaseBuyWidget(
            address: account.address.address
        )
        navigationController.openURL(widget.url)
    }
}
