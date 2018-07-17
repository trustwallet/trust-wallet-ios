// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore
import TrustCore

struct WalletInfo {
    let wallet: WalletStruct
    let info: WalletObject

    var address: Address {
        return wallet.address
    }

    var mainWallet: Bool {
        return info.mainWallet
    }

    var accounts: [Account] {
        switch wallet.type {
        case .privateKey(let account), .hd(let account):
            return account.accounts
        case .address(let address):
            return [
                Account(wallet: .none, address: address, derivationPath: Coin.ethereum.derivationPath(at: 0)),
            ]
        }
    }

    var currentAccount: Account? {
        switch wallet.type {
        case .privateKey, .hd: return accounts.first
        case .address: return .none
        }
    }

    var currentWallet: Wallet? {
        switch wallet.type {
        case .privateKey(let wallet), .hd(let wallet):
            return wallet
        case .address:
            return .none
        }
    }

    var isWatch: Bool {
        switch wallet.type {
        case .privateKey, .hd:
            return false
        case .address:
            return true
        }
    }

    init(
        type: WalletType,
        wallet: WalletStruct,
        info: WalletObject? = .none
    ) {
        self.wallet = wallet
        self.info = info ?? WalletObject.from(wallet)
    }
}

extension WalletInfo: Equatable {
    static func == (lhs: WalletInfo, rhs: WalletInfo) -> Bool {
        return lhs.wallet.description == rhs.wallet.description
    }
}
