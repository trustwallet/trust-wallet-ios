// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore
import TrustCore

struct WalletInfo {
    let type: WalletType
    let info: WalletObject

    var address: Address {
        switch type {
        case .privateKey, .hd:
            return currentAccount.address
        case .address(_, let address):
            return address
        }
    }

    var coin: Coin? {
        switch type {
        case .privateKey, .hd:
            guard let account = currentAccount,
                let coin = Coin(rawValue: account.derivationPath.coinType) else {
                    return .none
            }
            return coin
        case .address(let coin, _):
            return coin
        }
    }

    var mainWallet: Bool {
        return info.mainWallet
    }

    var accounts: [Account] {
        switch type {
        case .privateKey(let account), .hd(let account):
            return account.accounts
        case .address(let coin, let address):
            return []
        }
    }

    var currentAccount: Account! {
        NSLog("accounts \(accounts.count)")
        NSLog("type \(type)")
        switch type {
        case .privateKey, .hd:
            return accounts.filter { $0.description == info.selectedAccount }.first ?? accounts.first!
        case .address(let coin, let address):
            return Account(wallet: .none, address: address, derivationPath: coin.derivationPath(at: 0))
        }
    }

    var currentWallet: Wallet? {
        switch type {
        case .privateKey(let wallet), .hd(let wallet):
            return wallet
        case .address:
            return .none
        }
    }

    var isWatch: Bool {
        switch type {
        case .privateKey, .hd:
            return false
        case .address:
            return true
        }
    }

    init(
        type: WalletType,
        info: WalletObject? = .none
    ) {
        self.type = type
        self.info = info ?? WalletObject.from(type)
    }

    var description: String {
        return type.description
    }

    var chainID: Int {
        switch coin {
        case .none: return -1
        case .some(let coin):
            switch coin {
            case .poa: return RPCServer.poa.chainID
            case .bitcoin: return 0
            case .ethereum: return RPCServer.main.chainID
            case .ethereumClassic: return RPCServer.classic.chainID
            case .callisto: return RPCServer.callisto.chainID
            case .gochain: return RPCServer.gochain.chainID
            }
        }
    }
}

extension WalletInfo: Equatable {
    static func == (lhs: WalletInfo, rhs: WalletInfo) -> Bool {
        return lhs.type.description == rhs.type.description
    }
}
