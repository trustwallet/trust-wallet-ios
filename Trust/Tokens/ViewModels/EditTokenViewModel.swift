// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Moya

enum EditTokenSection: Int {
    case search = 0
    case local
}

class EditTokenViewModel {

    let network: NetworkProtocol
    let storage: TokensDataStore
    let config: Config
    let tableView: UITableView
    let feedbackGenerator = UINotificationFeedbackGenerator()

    var searchResults = [TokenObject]()
    var filteredTokens = [TokenObject]()
    var isSearching = false
    var localSet = Set<TokenObject>()

    init(network: NetworkProtocol,
         storage: TokensDataStore,
         config: Config,
         table: UITableView
    ) {
        self.network = network
        self.storage = storage
        self.config = config
        self.tableView = table

        self.localSet = Set(storage.objects)
    }

    var title: String {
        return NSLocalizedString("Tokens", value: "Tokens", comment: "")
    }

    var searchPlaceholder: String {
        return NSLocalizedString("editTokens.searchBar.placeholder.title", value: "Search tokens", comment: "")
    }

    var numberOfSections: Int {
        return 2
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        if section == EditTokenSection.search.rawValue {
            return searchResults.count
        } else {
            if isSearching {
                return filteredTokens.count
            }
            return storage.objects.count
        }
    }

    func token(for indexPath: IndexPath) -> (token: TokenObject, local: Bool) {
        if indexPath.section == EditTokenSection.search.rawValue {
            return (searchResults[indexPath.row], false)
        } else {
            if isSearching {
                return (filteredTokens[indexPath.row], true)
            }
            return (storage.objects[indexPath.row], true)
        }
    }

    func didSelectRowAt(_ indexPath: IndexPath) -> Bool {
        let pair = token(for: indexPath)
        if !pair.local {
            storage.add(tokens: [pair.token])
            feedbackGenerator.notificationOccurred(.success)
            return true
        }
        return false
    }

    func search(token: String) {
        isSearching = !token.isEmpty
        if !self.isSearching {
            searchResults.removeAll()
            filteredTokens.removeAll()
            tableView.reloadData()
        } else {
            filter(for: token)
            network.search(token: token) { [weak self] (tokens) in
                guard let strongSelf = self else { return }
                tokens.forEach {
                    $0.isCustom = true
                    $0.isDisabled = false
                }
                strongSelf.searchResults = tokens.filter { !strongSelf.localSet.contains($0) }
                strongSelf.tableView.reloadData()
            }
        }
    }

    func filter(for searchText: String?) {
        let text = searchText?.lowercased() ?? ""
        self.filteredTokens = storage.objects.filter { $0.name.lowercased().contains(text) || $0.symbol.lowercased().contains(text) }
    }

    func updateToken(indexPath: IndexPath, action: TokenAction) {
        let token = self.token(for: indexPath)
        self.storage.update(tokens: [token.token], action: action)
    }
}
