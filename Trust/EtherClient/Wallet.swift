// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

struct Wallet {

    struct Keys {
        static let walletPrivateKey = "wallet-private-key-"
        static let walletHD = "wallet-hd-wallet-"
        static let address = "wallet-address-"
    }

    let type: WalletType

    var address: Address {
        switch type {
        case .privateKey(let account):
            return account.address
        case .hd(let account):
            return account.address
        case .address(let address):
            return address
        }
    }

    var description: String {
        switch self.type {
        case .privateKey(let account):
            return Keys.walletPrivateKey + account.address.description
        case .hd(let account):
            return Keys.walletHD + account.address.description
        case .address(let address):
            return Keys.address + address.description
        }
    }
}

extension Wallet: Equatable {
    static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.description == rhs.description
    }
}
