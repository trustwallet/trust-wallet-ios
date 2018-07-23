// Copyright DApps Platform Inc. All rights reserved.

import Foundation

enum WalletDoneType {
    case created
    case imported

    var title: String {
        switch self {
        case .created: return R.string.localizable.walletCreated()
        case .imported: return "Wallet Imported"
        }
    }
}

struct WalletCreatedViewModel {

    let wallet: WalletInfo
    let type: WalletDoneType

    var title: String {
        return wallet.info.name
    }

    var subtitle: String {
        if wallet.multiWallet {
            return R.string.localizable.multiCoinWallet()
        }
        return wallet.address.description
    }
}
