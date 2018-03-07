// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

struct AccountsViewModel {

    private struct Sections {
        static let hdWallets = 0
        static let regularWallets = 1
    }

    private let regularWallets: [Wallet]
    private let hdWallets: [Wallet]

    init(wallets: [Wallet]) {
        self.hdWallets = wallets.filter { wallet in
            switch wallet.type {
            case .hd: return true
            case .privateKey, .address: return false
            }
        }
        self.regularWallets = wallets.filter { wallet in
            switch wallet.type {
            case .privateKey, .address:
                return true
            case .hd: return false
            }
        }
    }

    var title: String {
        return NSLocalizedString("wallet.navigation.title", value: "Wallets", comment: "")
    }

    var numberOfSections: Int {
        return 2
    }

    func wallet(for indexPath: IndexPath) -> Wallet? {
        switch indexPath.section {
        case Sections.hdWallets:
            return hdWallets[indexPath.row]
        case Sections.regularWallets:
            return regularWallets[indexPath.row]
        default: return .none
        }
    }

    func numberOfRows(in section: Int) -> Int {
        switch section {
        case Sections.hdWallets:
            return hdWallets.count
        case Sections.regularWallets:
            return regularWallets.count
        default: return 0
        }
    }

    var isLastWallet: Bool {
        return (hdWallets.count + regularWallets.count) <= 1
    }

    func titleForHeader(in section: Int) -> String? {
        switch section {
        case Sections.hdWallets:
            return hdWallets.isEmpty ? .none : NSLocalizedString("wallet.section.hdWallet.title", value: "HD Wallet", comment: "")
        case Sections.regularWallets:
            return .none
        default: return .none
        }
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
