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
    mutating func setTokenObservation(with block: @escaping (RealmCollectionChange<Results<NonFungibleTokenObject>>) -> Void) {
        tokensObserver = tokens.observe(block)
    }
    func cellViewModel(for path: IndexPath) -> NonFungibleTokenCellViewModel {
        let token = tokens[path.row]
        return NonFungibleTokenCellViewModel(token: token)
    }
    var hasContent: Bool {
        return !tokens.isEmpty
    }
}
