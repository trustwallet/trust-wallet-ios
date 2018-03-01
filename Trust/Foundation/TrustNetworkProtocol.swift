// Copyright SIX DAY LLC. All rights reserved.

import Moya

protocol TrustNetworkProtocol {
    var provider: MoyaProvider<TrustService> { get }
    var balanceService: TokensBalanceService { get }
    var account: Wallet { get }
    var config: Config { get }
    init(provider: MoyaProvider<TrustService>, balanceService: TokensBalanceService, account: Wallet, config: Config)
}
