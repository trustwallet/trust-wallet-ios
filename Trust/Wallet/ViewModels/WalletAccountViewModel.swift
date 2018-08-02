// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore
import TrustCore
import BigInt

struct WalletAccountViewModel {
    let keystore: Keystore
    let wallet: WalletInfo
    let account: Account
    let currentWallet: WalletInfo?
    private let shortFormatter = EtherNumberFormatter.short

    var title: String {
        if wallet.multiWallet {
            return wallet.info.name
        }
        if !wallet.info.name.isEmpty {
            return  wallet.info.name + " (" + wallet.coin!.server.symbol + ")"
        }
        return WalletInfo.emptyName
    }

    var isBalanceHidden: Bool {
        return wallet.multiWallet
    }

    var address: String {
        guard wallet.multiWallet else {
             return account.address.description
        }
        return R.string.localizable.multiCoinWallet()
    }

    var balance: String {
        guard !wallet.info.balance.isEmpty, let server = wallet.coin?.server else {
            return  WalletInfo.format(value: "0.0", server: .main)
        }
        return WalletInfo.format(value: shortFormatter.string(from: BigInt(wallet.info.balance) ?? BigInt(), decimals: server.decimals), server: server)
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
        return currentWallet != wallet // || keystore.wallets.count == 1
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
