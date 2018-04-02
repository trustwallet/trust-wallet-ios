// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore

enum TransferType {
    case ether(destination: Address?)
    case token(TokenObject)
    case dapp
}

extension TransferType {
    func symbol(server: RPCServer) -> String {
        switch self {
        case .ether, .dapp:
            return server.symbol
        case .token(let token):
            return token.symbol
        }
    }

    // Used to fetch pricing for specific token
    func contract() -> Address {
        switch self {
        case .ether, .dapp:
            return Address(string: TokensDataStore.etherToken(for: Config()).contract)!
        case .token(let token):
            return Address(string: token.contract)!
        }
    }
}
