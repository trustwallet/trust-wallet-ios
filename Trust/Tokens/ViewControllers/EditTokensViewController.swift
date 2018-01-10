// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class EditTokensViewController: UITableViewController {

    let session: WalletSession
    let storage: TokensDataStore
    let viewModel = EditTokenViewModel()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredTokens = [TokenObject]()

    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }

    init(
        session: WalletSession,
        storage: TokensDataStore
    ) {
        self.session = session
        self.storage = storage

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = viewModel.title
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = NSLocalizedString("editTokens.searchBar.placeholder.title", value: "Search tokens", comment: "")
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        tableView.register(R.nib.editTokenTableViewCell(), forCellReuseIdentifier: R.nib.editTokenTableViewCell.name)
        tableView.tableHeaderView = searchController.searchBar
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredTokens.count
        }
        return storage.objects.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.editTokenTableViewCell.name, for: indexPath) as! EditTokenTableViewCell
        cell.delegate = self
        let token = self.token(for: indexPath)
        cell.viewModel = EditTokenTableCellViewModel(
            token: token,
            coinTicker: storage.coinTicker(for: token)
        )
        return cell
    }

    func token(for indexPath: IndexPath) -> TokenObject {
        if isFiltering {
            return filteredTokens[indexPath.row]
        }
        return storage.objects[indexPath.row]
    }

    func filter(for searchText: String?) {
        let text = searchText?.lowercased() ?? ""
        filteredTokens = storage.objects.filter { $0.name.lowercased().contains(text) || $0.symbol.lowercased().contains(text) }
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditTokensViewController: EditTokenTableViewCellDelegate {
    func didChangeState(state: Bool, in cell: EditTokenTableViewCell) {

    guard let indexPath = tableView.indexPath(for: cell) else { return }

    storage.update(token: token(for: indexPath), action: .isDisabled(!state))
    }
}

extension EditTokensViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filter(for: searchBar.text)
    }
}

extension EditTokensViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filter(for: searchController.searchBar.text)
    }
}
