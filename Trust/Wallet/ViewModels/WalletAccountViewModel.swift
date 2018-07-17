// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore
import TrustCore

struct WalletAccountViewModel {

    let wallet: WalletInfo
    let account: Account

    var title: String {
        guard let coin = Coin(rawValue: account.derivationPath.coinType) else {
            return R.string.localizable.transactionCellUnknownTitle()
        }
        return CoinViewModel(coin: coin).name + " " + R.string.localizable.wallet()
    }

    var subbtitle: String {
        return account.address.description
    }
}
