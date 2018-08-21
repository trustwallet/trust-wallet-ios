// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import Moya
import RealmSwift

final class EditTokenViewModel {

    let network: NetworkProtocol
    let storage: TokensDataStore

    private var tokens: Results<TokenObject> {
        return storage.realm.objects(TokenObject.self).sorted(byKeyPath: "order", ascending: true)
    }

    var localSet = Set<TokenObject>()

    init(
        network: NetworkProtocol,
        storage: TokensDataStore
    ) {
        self.network = network
        self.storage = storage

        self.localSet = Set(tokens)
    }

    var title: String {
        return R.string.localizable.tokens()
    }

    var searchPlaceholder: String {
        return R.string.localizable.editTokensSearchBarPlaceholderTitle()
    }

    var numberOfSections: Int {
        return 1
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return tokens.count
    }

    func token(for indexPath: IndexPath) -> (token: TokenObject, local: Bool) {
        return (tokens[indexPath.row], true)
    }

    func canEdit(for path: IndexPath) -> Bool {
        return tokens[path.row].isCustom
    }

    func searchNetwork(token: String, completion: (([TokenObject]) -> Void)?) {
        network.search(query: token).done { [weak self] tokens in
            var filterSet = Set<TokenObject>()
            if let localSet = self?.localSet {
                filterSet = localSet
            }
            tokens.forEach {
                $0.isCustom = true
                $0.isDisabled = false
            }
            completion?(tokens.filter { !filterSet.contains($0) })
        }.catch { _ in }
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
