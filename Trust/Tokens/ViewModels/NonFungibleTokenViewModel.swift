// Copyright SIX DAY LLC. All rights reserved.

import RealmSwift

struct NonFungibleTokenViewModel {
    let config: Config
    let realmDataStore: TokensDataStore
    var tokensNetwork: TokensNetworkProtocol
    let tokens: Results<NonFungibleTokenObject>
    var tokensObserver: NotificationToken?
    init(
        config: Config = Config(),
        realmDataStore: TokensDataStore,
        tokensNetwork: TokensNetworkProtocol
        ) {
        self.config = config
        self.realmDataStore = realmDataStore
        self.tokensNetwork = tokensNetwork
        self.tokens = realmDataStore.nonFungibleTokens
    }
}
