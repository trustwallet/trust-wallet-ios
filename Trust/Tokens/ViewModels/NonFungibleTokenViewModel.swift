// Copyright SIX DAY LLC. All rights reserved.

import RealmSwift
import TrustCore
import PromiseKit

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
        return AppStyle.collactablesHeader.textColor
    }

    var tableViewBacgroundColor: UIColor {
        return UIColor.white
    }

    var headerTitleFont: UIFont {
        return AppStyle.collactablesHeader.font
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

    func fetchAssets() -> Promise<[NonFungibleTokenCategory]> {
        return Promise { seal in
            firstly {
                tokensNetwork.assets()
            }.done { [weak self] tokens in
                self?.storage.add(tokens: tokens)
                seal.fulfill(tokens)
            }.catch { error in
                seal.reject(error)
            }
        }
    }

    func setTokenObservation(with block: @escaping (RealmCollectionChange<Results<NonFungibleTokenCategory>>) -> Void) {
        tokensObserver = tokens.observe(block)
    }

    func token(for path: IndexPath) -> NonFungibleTokenObject {
        return tokens[path.section].items[path.row]
    }

    func tokens(for path: IndexPath) -> [NonFungibleTokenObject] {
        return Array(tokens[path.section].items)
    }

    func cellViewModel(for path: IndexPath) -> NonFungibleTokenCellViewModel {
        return NonFungibleTokenCellViewModel(tokens: tokens(for: path))
    }

    func numberOfItems(in section: Int) -> Int {
        return 1
    }

    func numberOfSections() -> Int {
        return Array(tokens).map { $0.name }.count
    }

    func title(for section: Int) -> String {
        return tokens[section].name
    }

    func invalidateTokensObservation() {
        tokensObserver?.invalidate()
        tokensObserver = nil
    }
}
