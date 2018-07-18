// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore
import TrustCore

struct WalletAccountViewModel {
    let wallet: WalletInfo
    let account: Account

    var title: String {
        guard !wallet.mainWallet else {
            guard let coin = account.coin else {
                return R.string.localizable.transactionCellUnknownTitle()
            }
            let viewModel = CoinViewModel(coin: coin)
            return viewModel.name + " (" + viewModel.symbol + ")"
        }
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
        switch coin {
        case .bitcoin: return .none
        case .ethereum: return R.image.ethereum_1()
        case .ethereumClassic: return R.image.ethereum61()
        case .poa: return R.image.ethereum99()
        case .callisto: return R.image.ethereum820()
        case .gochain: return R.image.ethereum60()
        }
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
