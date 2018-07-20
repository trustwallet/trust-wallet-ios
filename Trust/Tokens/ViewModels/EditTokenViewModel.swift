// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import Moya

final class EditTokenViewModel {

    let network: NetworkProtocol
    let storage: TokensDataStore
    let config: Config

    var localSet = Set<TokenObject>()

    init(network: NetworkProtocol,
         storage: TokensDataStore,
         config: Config
    ) {
        self.network = network
        self.storage = storage
        self.config = config

        self.localSet = Set(storage.objects)
    }

    var title: String {
        return NSLocalizedString("Tokens", value: "Tokens", comment: "")
    }

    var searchPlaceholder: String {
        return NSLocalizedString("editTokens.searchBar.placeholder.title", value: "Search tokens", comment: "")
    }

    var numberOfSections: Int {
        return 1
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return storage.objects.count
    }

    func token(for indexPath: IndexPath) -> (token: TokenObject, local: Bool) {
        return (storage.objects[indexPath.row], true)
    }

    func searchNetwork(token: String, completion: (([TokenObject]) -> Void)?) {
        network.search(token: token).done { [weak self] tokens in
            var filterSet = Set<TokenObject>()
            if let localSet = self?.localSet {
                filterSet = localSet
            }
            tokens.forEach {
                $0.isCustom = true
                $0.isDisabled = false
            }
            completion?(tokens.filter { !filterSet.contains($0) })
        }
    }

    func searchLocal(token searchText: String?) -> [TokenObject] {
        let text = searchText?.lowercased() ?? ""
        let filteredTokens = storage.objects.filter { $0.name.lowercased().contains(text) || $0.symbol.lowercased().contains(text) }
        return filteredTokens
    }

    func updateToken(indexPath: IndexPath, action: TokenAction) {
        let token = self.token(for: indexPath)
        self.storage.update(tokens: [token.token], action: action)
    }
}
