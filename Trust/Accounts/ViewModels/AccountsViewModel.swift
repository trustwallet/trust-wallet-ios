// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore

struct AccountsViewModel {

    private var walletsTypes = [[WalletInfo]]()
    private var shouldShowHdWalletsTitle = false
    let current: WalletInfo
    init(
        wallets: [WalletInfo],
        current: WalletInfo
    ) {
        self.current = current
        let hdWallets = wallets.filter { wallet in
            switch wallet.wallet.type {
            case .hd: return true
            case .privateKey, .address: return false
            }
        }

        if !hdWallets.isEmpty {
            shouldShowHdWalletsTitle = true
            walletsTypes.append(hdWallets)
        }

        let regularWallets = wallets.filter { wallet in
            switch wallet.wallet.type {
            case .privateKey, .address:
                return true
            case .hd: return false
            }
        }

        if !regularWallets.isEmpty {
            walletsTypes.append(regularWallets)
        }
    }

    var title: String {
        return R.string.localizable.wallets()
    }

    var numberOfSections: Int {
        return walletsTypes.count
    }

    func wallet(for indexPath: IndexPath) -> WalletInfo? {
        return walletsTypes[indexPath.section][indexPath.row]
    }

    func canEditRowAt(for indexPath: IndexPath) -> Bool {
        return (current != wallet(for: indexPath) || isLastWallet)
    }

    func numberOfRows(in section: Int) -> Int {
        return walletsTypes[section].count
    }

    var isLastWallet: Bool {
        return walletsTypes.flatMap { $0 }.count <= 1
    }

    func titleForHeader(in section: Int) -> String? {
        guard shouldShowHdWalletsTitle && section == 0 else {
            return nil
        }
        return NSLocalizedString("wallet.section.hdWallet.title", value: "HD Wallet", comment: "")
    }

    func headerHeight(in section: Int) -> CGFloat {
        guard let _ = titleForHeader(in: section) else {
            return 0.01
        }
        return StyleLayout.TableView.heightForHeaderInSection
    }

    func footerHeight(in section: Int) -> CGFloat {
        return headerHeight(in: section)
    }
}
