// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class EditTokensViewController: UITableViewController {

    let session: WalletSession
    let storage: TokensDataStore
    let network: NetworkProtocol

    lazy var viewModel: EditTokenViewModel = {
        return EditTokenViewModel(
            network: network,
            storage: storage,
            config: session.config,
            table: tableView
        )
    }()

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = viewModel.searchPlaceholder
        searchController.searchBar.sizeToFit()
        searchController.searchBar.barTintColor = Colors.lightGray
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        return searchController
    }()

    lazy var searchClosure: (String) -> Void = {
        return debounce(delay: .milliseconds(250), action: { [weak self] (query) in
            self?.viewModel.search(token: query)
        })
    }()

    init(
        session: WalletSession,
        storage: TokensDataStore,
        network: NetworkProtocol
    ) {
        self.session = session
        self.storage = storage
        self.network = network

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = viewModel.title
        configureTableView()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        tableView.reloadData()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRowsInSection(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.editTokenTableViewCell.name, for: indexPath) as! EditTokenTableViewCell
        cell.delegate = self
        let token = self.viewModel.token(for: indexPath)
        cell.viewModel = EditTokenTableCellViewModel(
            token: token.token,
            coinTicker: storage.coinTicker(for: token.token),
            config: session.config,
            isLocal: token.local
        )
        cell.separatorInset = TokensLayout.tableView.layoutInsets
        cell.selectionStyle = token.local ? .none : .default
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TokensLayout.tableView.height
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if viewModel.didSelectRowAt(indexPath) {
            searchController.isActive = false
            searchBarCancelButtonClicked(searchController.searchBar)
        }
    }

    func configureTableView() {
        tableView.register(R.nib.editTokenTableViewCell(), forCellReuseIdentifier: R.nib.editTokenTableViewCell.name)
        tableView.tableHeaderView = searchController.searchBar
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = TokensLayout.tableView.separatorColor
        tableView.separatorInset = TokensLayout.tableView.layoutInsets
        tableView.backgroundColor = .white
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension EditTokensViewController: EditTokenTableViewCellDelegate {
    func didChangeState(state: Bool, in cell: EditTokenTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else {
            return
        }
        self.viewModel.updateToken(indexPath: indexPath, action: .disable(!state))
    }
}

extension EditTokensViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchClosure(searchBar.text ?? "")
    }

    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        self.searchClosure(searchBar.text ?? "")
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.viewModel.search(token: "")
    }
}

extension EditTokensViewController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.barTintColor = Colors.blue
        searchController.searchBar.tintColor = .white
    }

    func willDismissSearchController(_ searchController: UISearchController) {
        searchController.searchBar.barTintColor = Colors.lightGray
        searchController.searchBar.tintColor = Colors.blue
    }
}

extension EditTokensViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        self.searchClosure(searchController.searchBar.text ?? "")
    }
}
