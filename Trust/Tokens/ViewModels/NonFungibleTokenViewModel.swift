// Copyright SIX DAY LLC. All rights reserved.

import RealmSwift
import TrustKeystore

struct NonFungibleTokenViewModel {
    
    let config: Config
    
    let storage: TokensDataStore
    
    var tokensNetwork: TokensNetworkProtocol
    
    let tokens: Results<NonFungibleTokenCategory>
    
    var tokensObserver: NotificationToken?
    
    let address: Address
    
    var hasContent: Bool {
        return !tokens.isEmpty
    }
    
    init(
        address: Address,
        config: Config = Config(),
        storage: TokensDataStore,
        tokensNetwork: TokensNetworkProtocol
    ) {
        self.address = address
        self.config = config
        self.storage = storage
        self.tokensNetwork = tokensNetwork
        self.tokens = storage.nonFungibleTokens
    }
    
    func fetchAssets() {
        self.tokensNetwork.assets { assets in
            guard let tokens = assets else { return }
            self.storage.add(tokens: tokens)
        }
    }

    mutating func setTokenObservation(with block: @escaping (RealmCollectionChange<Results<NonFungibleTokenCategory>>) -> Void) {
        tokensObserver = tokens.observe(block)
    }

    func cellViewModel(for path: IndexPath) -> NonFungibleTokenCellViewModel {
        let token = tokens[path.section].items[path.row]
        return NonFungibleTokenCellViewModel(token: token)
    }
}
