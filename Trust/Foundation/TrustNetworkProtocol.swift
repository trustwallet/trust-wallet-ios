// Copyright DApps Platform Inc. All rights reserved.

import Moya

protocol TrustNetworkProtocol {
    var provider: MoyaProvider<TrustService> { get }
    var APIProvider: MoyaProvider<TrustAPI> { get }
    var balanceService: TokensBalanceService { get }
    var account: WalletInfo { get }
    var config: Config { get }
    init(provider: MoyaProvider<TrustService>, APIProvider: MoyaProvider<TrustAPI>, balanceService: TokensBalanceService, account: WalletInfo, config: Config)
}
