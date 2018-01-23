// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

enum TransferType {
    case ether(destination: Address?)
    case token(TokenObject)
}

extension TransferType {
    func symbol(server: RPCServer) -> String {
        switch self {
        case .ether:
            return server.symbol
        case .token(let token):
            return token.symbol
        }
    }

    func contract() -> String {
        switch self {
        case .ether:
            return TokensDataStore.etherToken(for: Config()).contract
        case .token(let token):
            return token.contract
        }
    }
}
