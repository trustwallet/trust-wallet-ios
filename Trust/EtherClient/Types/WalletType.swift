// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

enum WalletType {
    case privateKey(Account)
    case hd(Account)
    case address(Address)
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
