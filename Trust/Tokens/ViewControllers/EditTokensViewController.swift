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
            config: session.config
        )
    }()

    lazy var searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: self.searchResultsController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = viewModel.searchPlaceholder
        searchController.searchBar.sizeToFit()
        searchController.searchBar.barTintColor = Colors.lightGray
        searchController.searchBar.delegate = self
        definesPresentationContext = true
        return searchController
    }()

    lazy var searchResultsController: SearchTokenResultsController = {
        let resultsController = SearchTokenResultsController()
        resultsController.delegate = self
        return resultsController
    }()

    lazy var searchClosure: (String) -> Void = {
        return debounce(delay: .milliseconds(250), action: { [weak self] (query) in
            self?.search(token: query)
        })
    }()

    let feedbackGenerator = UINotificationFeedbackGenerator()

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

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
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
        let token = self.viewModel.token(for: indexPath)
        configCell(cell, token: token)
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TokensLayout.tableView.height
    }

    func configureTableView() {
        tableView.register(R.nib.editTokenTableViewCell(), forCellReuseIdentifier: R.nib.editTokenTableViewCell.name)
        tableView.tableHeaderView = searchController.searchBar
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = StyleLayout.TableView.separatorColor
        tableView.separatorInset = TokensLayout.tableView.layoutInsets
        tableView.backgroundColor = .white
        tableView.cellLayoutMarginsFollowReadableWidth = false
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .onDrag
    }

    private func configCell(_ cell: EditTokenTableViewCell, token: (token: TokenObject, local: Bool)) {
        cell.viewModel = EditTokenTableCellViewModel(
            token: token.token,
            coinTicker: storage.coinTicker(for: token.token),
            config: session.config,
            isLocal: token.local
        )
        cell.separatorInset = TokensLayout.tableView.layoutInsets
        cell.selectionStyle = token.local ? .none : .default
    }

    private func search(token: String) {
        let localResults = viewModel.searchLocal(token: token)
        searchResultsController.localResults = localResults
        viewModel.searchNetwork(token: token) { [weak self] (tokens) in
            self?.searchResultsController.remoteResults = tokens
        }
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

extension EditTokensViewController: SearchTokenResultsControllerDelegate {
    func searchResultsController(configureCell cell: EditTokenTableViewCell, with token: (token: TokenObject, local: Bool)) {
        self.configCell(cell, token: token)
    }

    func searchResultsController(didSelect cell: EditTokenTableViewCell, with token: (token: TokenObject, local: Bool)) {
        if !token.local {
            storage.add(tokens: [token.token])
            feedbackGenerator.notificationOccurred(.success)
            searchController.isActive = false
            searchBarCancelButtonClicked(searchController.searchBar)
            tableView.reloadData()
        }
    }

    func searchResultsController(didUpdate token: TokenObject, with action: TokenAction) {
        self.storage.update(tokens: [token], action: action)
        tableView.reloadData()
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
        self.search(token: "")
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
