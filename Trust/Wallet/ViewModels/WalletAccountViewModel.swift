// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore
import TrustCore

struct WalletAccountViewModel {

    let wallet: WalletInfo
    let account: Account?

    var title: String {
        guard let coin = account?.coin else {
            return R.string.localizable.transactionCellUnknownTitle()
        }
        let viewModel = CoinViewModel(coin: coin)
        return viewModel.name + " (" + viewModel.symbol + ")"
    }

    var subbtitle: String {
        return account?.address.description ?? ""
    }
}

extension Account {
    var coin: Coin? {
        return Coin(rawValue: derivationPath.coinType)
    }

    var uniqueID: String {
        return derivationPath.description + "-" + address.description
    }
}
