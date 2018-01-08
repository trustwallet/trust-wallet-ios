// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

enum WalletType {
    case real(Account)
    case watch(Address)
}

extension WalletType: Equatable {
    static func == (lhs: WalletType, rhs: WalletType) -> Bool {
        switch (lhs, rhs) {
        case (let .real(lhs), let .real(rhs)):
            return lhs == rhs
        case (let .watch(lhs), let .watch(rhs)):
            return lhs == rhs
        case (.real, .watch),
             (.watch, .real):
            return false
        }
    }
}

struct Wallet {
    let type: WalletType

    var address: Address {
        switch type {
        case .real(let account):
            return account.address
        case .watch(let address):
            return address
        }
    }
}

extension Wallet: Equatable {
    static func == (lhs: Wallet, rhs: Wallet) -> Bool {
        return lhs.type == rhs.type
    }
}
