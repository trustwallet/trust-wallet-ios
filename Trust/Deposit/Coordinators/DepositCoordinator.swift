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
            message: NSLocalizedString("deposit.alertSheetMessage", value: "How would you like to buy?", comment: ""),
            preferredStyle: .actionSheet
        )
        let coinbaseAction = UIAlertAction(title: NSLocalizedString("deposit.viaCoinbase", value: "via Coinbase", comment: ""), style: .default) { _ in
            self.showCoinbase()
        }
        let shapeShiftAction = UIAlertAction(title: NSLocalizedString("deposit.viaShapeShift", value: "via ShapeShift", comment: ""), style: .default) { _ in
            self.showShapeShift()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("generic.cancel", value: "Cancel", comment: ""), style: .cancel) { _ in }

        alertController.addAction(coinbaseAction)
        alertController.addAction(shapeShiftAction)
        alertController.addAction(cancelAction)
        navigationController.present(alertController, animated: true, completion: nil)
    }

    func showCoinbase() {
        let widget = CoinbaseBuyWidget(
            address: account.address.address
        )
        navigationController.openURL(widget.url)
    }

    func showShapeShift() {
        let widget = ShapeShiftBuyWidget(
            address: account.address.address
        )
        navigationController.openURL(widget.url)
    }
}
