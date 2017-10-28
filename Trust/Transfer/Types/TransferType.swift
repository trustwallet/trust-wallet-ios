// Copyright SIX DAY LLC. All rights reserved.

import Foundation

enum TransferType {
    case ether(destination: Address?)
    case token(Token)
}

extension TransferType {
    var symbol: String {
        switch self {
        case .ether:
            return "ETH"
        case .token(let token):
            return token.symbol
        }
    }
}
