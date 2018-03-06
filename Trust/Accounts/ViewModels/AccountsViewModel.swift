// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

struct AccountsViewModel {

    private let regularWallets: [Wallet]
    private let hdWallets: [Wallet]

    init(wallets: [Wallet]) {
        self.hdWallets = wallets.filter { wallet in
            switch wallet.type {
            case .real(let account):
                return account.type == .hierarchicalDeterministicWallet
            case .watch:
                return false
            }
        }
        self.regularWallets = wallets.filter { wallet in
            switch wallet.type {
            case .real(let account):
                return account.type == .encryptedKey
            case .watch:
                return true
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
        case 0:
            return hdWallets[indexPath.row]
        case 1:
            return regularWallets[indexPath.row]
        default: return .none
        }
    }

    func numberOfRows(in section: Int) -> Int {
        switch section {
        case 0:
            return hdWallets.count
        case 1:
            return regularWallets.count
        default: return 0
        }
    }

    var isLastWallet: Bool {
        return (hdWallets.count + regularWallets.count) <= 1
    }

    func titleForHeader(in section: Int) -> String? {
        switch section {
        case 0:
            return hdWallets.isEmpty ? .none : NSLocalizedString("wallet.section.hdWallet.title", value: "HD Wallet", comment: "")
        case 1:
            return regularWallets.isEmpty ? .none : NSLocalizedString("wallet.section.regularWallet.title", value: "Regular Wallet", comment: "")
        default: return .none
        }
    }
}
