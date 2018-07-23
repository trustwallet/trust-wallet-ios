// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustCore

class WalletsViewModel {

    private let keystore: Keystore
    private let networks: [WalletInfo] = []
    private let importedWallet: [WalletInfo] = []

    var sections: [WalletAccountViewModel] = []

    init(
        keystore: Keystore
    ) {
        self.keystore = keystore
    }

    func refresh() {
        self.sections = self.keystore.wallets.compactMap {
            return WalletAccountViewModel(wallet: $0, account: $0.currentAccount, currentWallet: keystore.recentlyUsedWallet)
        }
    }

    var title: String {
        return R.string.localizable.wallets()
    }

    var numberOfSection: Int {
        return 1
    }

    func numberOfRows(in section: Int) -> Int {
        return sections.count
    }

    func cellViewModel(for indexPath: IndexPath) -> WalletAccountViewModel {
        return sections[indexPath.row]
    }

    func canEditRowAt(for indexPath: IndexPath) -> Bool {
        return cellViewModel(for: indexPath).canDelete
    }
}
