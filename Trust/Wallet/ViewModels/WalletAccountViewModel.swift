// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore
import TrustCore

struct WalletAccountViewModel {
    let wallet: WalletInfo
    let account: Account
    let currentWallet: WalletInfo?

    var title: String {
        if wallet.multiWallet {
            return wallet.info.name
        }
        if !wallet.info.name.isEmpty {
            return  wallet.info.name + " (" + wallet.coin!.server.symbol + ")"
        }
        return WalletInfo.emptyName
    }

    var subbtitle: String {
        guard wallet.multiWallet else {
             return account.address.description
        }
        return R.string.localizable.multiCoinWallet()
    }

    var isWatch: Bool {
        return wallet.isWatch
    }

    var image: UIImage? {
        guard let coin = account.coin else { return .none }
        if wallet.multiWallet {
            return R.image.trust_icon()
        }
        return CoinViewModel(coin: coin).image
    }

    var selectedImage: UIImage? {
        if currentWallet == wallet {
            return R.image.blueCheck()
        }
        return .none
    }

    var canDelete: Bool {
        return !wallet.mainWallet && currentWallet != wallet
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
