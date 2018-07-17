// Copyright DApps Platform Inc. All rights reserved.

import Moya
import TrustCore

protocol TrustNetworkProtocol {
    var provider: MoyaProvider<TrustService> { get }
    var APIProvider: MoyaProvider<TrustAPI> { get }
    var balanceService: TokensBalanceService { get }
    var address: Address { get }
    var config: Config { get }
    init(provider: MoyaProvider<TrustService>, APIProvider: MoyaProvider<TrustAPI>, balanceService: TokensBalanceService, address: Address, config: Config)
}
