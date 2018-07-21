// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore
import TrustCore

struct WalletAccountViewModel {
    let wallet: WalletInfo
    let account: Account

    var title: String {
        guard wallet.info.name.isEmpty else {
            return wallet.info.name
        }
        return WalletInfo.emptyName
    }

    var subbtitle: String {
        return account.address.description
    }

    var isWatch: Bool {
        return wallet.isWatch
    }

    var image: UIImage? {
        guard let coin = account.coin else { return .none }
        return CoinViewModel(coin: coin).image
    }

    var canDelete: Bool {
        return !wallet.mainWallet
    }
}

extension Account {
    var coin: Coin? {
        return Coin(rawValue: derivationPath.coinType)
    }

    var description: String {
        return derivationPath.description + "-" + address.description
    }
}
