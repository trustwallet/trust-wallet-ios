// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore

struct WalletStruct {

    struct Keys {
        static let walletPrivateKey = "wallet-private-key-"
        static let walletHD = "wallet-hd-wallet-"
        static let address = "wallet-address-"
    }

    let type: WalletType

    var address: Address {
        switch type {
        case .privateKey(let account), .hd(let account):
            return account.accounts[0].address
        case .address(let address):
            return address
        }
    }

    var account: Account? {
        switch type {
        case .privateKey(let account), .hd(let account):
            return account.accounts[0]
        case .address: return .none
        }
    }

    var description: String {
        switch self.type {
        case .privateKey(let account):
            return Keys.walletPrivateKey + address.description
        case .hd(let account):
            return Keys.walletHD + address.description
        case .address(let address):
            return Keys.address + address.description
        }
    }
}

extension WalletStruct: Equatable {
    static func == (lhs: WalletStruct, rhs: WalletStruct) -> Bool {
        return lhs.description == rhs.description
    }
}
