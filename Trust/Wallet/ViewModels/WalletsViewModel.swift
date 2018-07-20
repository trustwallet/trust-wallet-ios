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

    func load(completion: (() -> Void)? = .none) {
        let walletInfo = keystore.mainWallet
        let wallet = walletInfo?.currentWallet

        DispatchQueue.global(qos: .userInitiated).async {

            let coins = Config.current.servers
            if let walletForAccount = wallet, walletForAccount.accounts.count < coins.count {
                let derivationPaths = coins.map { $0.derivationPath(at: 0) }
                let _ = self.keystore.addAccount(to: walletForAccount, derivationPaths: derivationPaths)
            }

            DispatchQueue.main.async {
//                let mainAccounts: [WalletAccountViewModel] = {
//                    guard let walletInfo = walletInfo else { return [] }
//                    return wallet?.accounts.compactMap { WalletAccountViewModel(wallet: walletInfo, account: $0) } ?? []
//                }()
//
//                self.sections = [
//                    mainAccounts,
//                    self.keystore.wallets.filter { !$0.mainWallet }.compactMap {
//                        return WalletAccountViewModel(wallet: $0, account: $0.currentAccount)
//                    },
//                ]

                self.sections = self.keystore.wallets.compactMap {
                    return WalletAccountViewModel(wallet: $0, account: $0.currentAccount)
                }

                completion?()
            }
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
        return false //(cellViewModel(for: indexPath).wallet != walletInfo?.currentWallet) ?? false
    }
}
