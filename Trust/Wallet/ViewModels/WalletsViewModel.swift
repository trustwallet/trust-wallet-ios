// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

class WalletsViewModel {

    private let keystore: Keystore
    private let networks: [WalletInfo] = []
    private let importedWallet: [WalletInfo] = []

    init(keystore: Keystore) {
        self.keystore = keystore
    }

    var title: String {
        return R.string.localizable.wallets()
    }

    var numberOfSection: Int {
        return 2
    }

    func numberOfRows(in section: Int) -> Int {
        switch section {
        case 0: return keystore.wallets.count //networks.count
        case 1: return keystore.wallets.count //importedWallet.count
        default: return 0
        }
    }

    func titleForHeader(in section: Int) -> String? {
        let enabled = numberOfRows(in: section) > 0
        switch section {
        case 0: return enabled ? R.string.localizable.mainWallet() : .none
        case 1: return enabled ? R.string.localizable.importedWallets() : .none
        default: return .none
        }
    }

    func heightForHeader(in section: Int) -> CGFloat {
        let enabled = numberOfRows(in: section) > 0
        return enabled ? StyleLayout.TableView.heightForHeaderInSection : 0.001
    }

    func cellViewModel(for indexPath: IndexPath) -> WalletInfoViewModel {
        return WalletInfoViewModel(wallet: keystore.wallets[0])
    }
}
