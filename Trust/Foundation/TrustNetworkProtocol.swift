// Copyright DApps Platform Inc. All rights reserved.

import Moya
import TrustCore

protocol TrustNetworkProtocol {
    var provider: MoyaProvider<TrustAPI> { get }
    var balanceService: TokensBalanceService { get }
    var address: Address { get }
    init(provider: MoyaProvider<TrustAPI>, balanceService: TokensBalanceService, address: Address, server: RPCServer)
}
