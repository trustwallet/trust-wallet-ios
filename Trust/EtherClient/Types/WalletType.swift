// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore

enum WalletType {
    struct Keys {
        static let walletPrivateKey = "wallet-private-key-"
        static let walletHD = "wallet-hd-wallet-"
        static let address = "wallet-address-"
    }

    case privateKey(Wallet)
    case hd(Wallet)
    case address(Coin, EthereumAddress)

    var description: String {
        switch self {
        case .privateKey(let account):
            return Keys.walletPrivateKey + account.identifier
        case .hd(let account):
            return Keys.walletHD + account.identifier
        case .address(let coin, let address):
            return Keys.address + "-" + "\(coin.rawValue)" + "-" + address.description
        }
    }
}

extension WalletType: Equatable {
    static func == (lhs: WalletType, rhs: WalletType) -> Bool {
        switch (lhs, rhs) {
        case (let .privateKey(lhs), let .privateKey(rhs)):
            return lhs == rhs
        case (let .hd(lhs), let .hd(rhs)):
            return lhs == rhs
        case (let .address(lhs), let .address(rhs)):
            return lhs == rhs
        case (.privateKey, _),
             (.hd, _),
             (.address, _):
            return false
        }
    }
}
