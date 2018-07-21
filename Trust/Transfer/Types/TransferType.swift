// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

struct Transfer {
    let server: RPCServer
    let type: TransferType
}

enum TransferType {
    case ether(TokenObject, destination: EthereumAddress?)
    case token(TokenObject)
    case dapp(TokenObject, DAppRequester)
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

    var priceID: String {
        switch self {
        case .ether(let token, _):
            return token.priceID
        case .dapp(let token, _):
            return token.priceID
        case .token(let token):
            return token.priceID
        }
    }
}
