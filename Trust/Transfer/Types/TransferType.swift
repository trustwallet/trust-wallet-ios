// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

struct Transfer {
    let server: RPCServer
    let type: TransferType
}

enum TransferType {
    case ether(destination: EthereumAddress?)
    case token(TokenObject)
    case nft(NonFungibleTokenObject)
    case dapp(DAppRequester)
}

extension TransferType {
    func symbol(server: RPCServer) -> String {
        switch self {
        case .ether, .dapp:
            return server.symbol
        case .nft:
            return "" //Doesn't really need :)
        case .token(let token):
            return token.symbol
        }
    }

    // Used to fetch pricing for specific token
    func contract() -> EthereumAddress {
        switch self {
        case .ether, .dapp:
            return EthereumAddress.zero
        case .nft(let token):
            return token.contractAddress
        case .token(let token):
            return token.contractAddress
        }
    }
}
