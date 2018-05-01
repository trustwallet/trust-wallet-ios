// Copyright SIX DAY LLC. All rights reserved.

import RealmSwift
import TrustCore

class NonFungibleTokenViewModel {

    let config: Config
    let storage: TokensDataStore
    var tokensNetwork: NetworkProtocol
    let tokens: Results<NonFungibleTokenCategory>
    var tokensObserver: NotificationToken?
    let address: Address

    var headerBackgroundColor: UIColor {
        return UIColor(hex: "fafafa")
    }

    var headerTitleTextColor: UIColor {
        return UIColor(hex: "555357")
    }

    var headerTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
    }

    var headerBorderColor: UIColor {
        return UIColor(hex: "e1e1e1")
    }

    var hasContent: Bool {
        return !tokens.isEmpty
    }

    init(
        address: Address,
        config: Config = Config(),
        storage: TokensDataStore,
        tokensNetwork: NetworkProtocol
    ) {
        self.address = address
        self.config = config
        self.storage = storage
        self.tokensNetwork = tokensNetwork
        self.tokens = storage.nonFungibleTokens
    }

    func fetchAssets( completion: @escaping (_ result: Bool) -> Void) {
        self.tokensNetwork.assets { assets in
            guard let tokens = assets else { return }
            completion(tokens.isEmpty)
            self.storage.add(tokens: tokens)
        }
    }

    func setTokenObservation(with block: @escaping (RealmCollectionChange<Results<NonFungibleTokenCategory>>) -> Void) {
        tokensObserver = tokens.observe(block)
    }

    func token(for path: IndexPath) -> [NonFungibleTokenObject] {
        return Array(tokens[path.section].items)
    }

    func cellViewModel(for path: IndexPath) -> NonFungibleTokenCellViewModel {
        return NonFungibleTokenCellViewModel(tokens: token(for: path))
    }

    func numberOfItems(in section: Int) -> Int {
        return 1
    }

    func numberOfSections() -> Int {
        return tokens.count
    }

    func title(for section: Int) -> String {
        return tokens[section].name
    }

    func invalidateTokensObservation() {
        tokensObserver?.invalidate()
        tokensObserver = nil
    }
}
