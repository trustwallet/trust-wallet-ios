// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustCore

class WalletsViewModel {

    private let keystore: Keystore
    private let networks: [WalletInfo] = []
    private let importedWallet: [WalletInfo] = []

    var sections: [[WalletAccountViewModel]] = []

    init(keystore: Keystore) {
        self.keystore = keystore
    }

    func load(completion: (() -> Void)? = .none) {
        let walletInfo = keystore.mainWallet
        let wallet = walletInfo?.currentWallet

        DispatchQueue.global(qos: .userInitiated).async {

            if let wallet = wallet {
                let _ = self.keystore.addAccount(to: wallet, derivationPaths: [
                    Coin.ethereum.derivationPath(at: 0),
                    Coin.callisto.derivationPath(at: 0),
                    Coin.poa.derivationPath(at: 0),
                    Coin.gochain.derivationPath(at: 0),
                ])
            }

            DispatchQueue.main.async {
                let mainAccounts: [WalletAccountViewModel] = {
                    guard let walletInfo = walletInfo else { return [] }
                    return wallet?.accounts.compactMap { WalletAccountViewModel(wallet: walletInfo, account: $0) } ?? []
                }()

                self.sections = [
                    mainAccounts,
                    self.keystore.wallets.filter { !$0.mainWallet }.compactMap {
                        return WalletAccountViewModel(wallet: $0, account: $0.accounts[0])
                    },
                ]
                completion?()
            }
        }
    }

    var title: String {
        return R.string.localizable.wallets()
    }

    var numberOfSection: Int {
        return sections.count
    }

    func numberOfRows(in section: Int) -> Int {
        return sections[section].count
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

    func cellViewModel(for indexPath: IndexPath) -> WalletAccountViewModel {
        return sections[indexPath.section][indexPath.row]
    }
}
