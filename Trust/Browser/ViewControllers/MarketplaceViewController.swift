// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StatefulViewController

protocol MarketplaceViewControllerDelegate: class {
    func didSelectItem(item: MarketplaceItem, in viewController: MarketplaceViewController)
}

class MarketplaceViewController: UITableViewController {

    let session: WalletSession
    let viewModel = MarketplaceViewModel()
    let searchController = UISearchController(searchResultsController: nil)
    var items = [MarketplaceItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    var filteredItems = [MarketplaceItem]()
    var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    var searchBarIsEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    weak var delegate: MarketplaceViewControllerDelegate?
    private let trustProvider = TrustProviderFactory.makeProvider()
    //let refreshControl = UIRefreshControl()

    init(
        session: WalletSession
    ) {
        self.session = session

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = viewModel.title
        //searchController.searchResultsUpdater = self
        //searchController.obscuresBackgroundDuringPresentation = false
        //searchController.searchBar.placeholder = NSLocalizedString("editTokens.searchBar.placeholder.title", value: "Search tokens", comment: "")
        //definesPresentationContext = true
        //searchController.searchBar.delegate = self
        tableView.register(R.nib.marketplaceItemTableViewCell(), forCellReuseIdentifier: R.nib.marketplaceItemTableViewCell.name)
        //tableView.tableHeaderView = searchController.searchBar
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.rowHeight = UITableViewAutomaticDimension

        refreshControl?.addTarget(self, action: #selector(fetch), for: .valueChanged)
        //tableView.addSubview(refreshControl)

        errorView = ErrorView(frame: view.frame)
        loadingView = LoadingView(frame: view.frame)
        emptyView = EmptyView(frame: view.frame)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        setupInitialViewState()
        fetch()
    }

    @objc func fetch() {
        startLoading()
        trustProvider.request(.marketplace) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                do {
                    self.items = try response.map(ArrayResponse<MarketplaceItem>.self).docs
                } catch {
                    self.handleError(error: error)
                }
            case .failure(let error):
                self.handleError(error: error)
            }
        }
    }

    func handleError(error: Error) {
        endLoading(error: error, completion: nil)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredItems.count
        }
        return items.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.marketplaceItemTableViewCell.name, for: indexPath) as! MarketplaceItemTableViewCell
        cell.viewModel = MarketplaceItemViewModel(item: item(for: indexPath))
        return cell
    }

    func item(for indexPath: IndexPath) -> MarketplaceItem {
        if isFiltering {
            return items[indexPath.row]
        }
        return items[indexPath.row]
    }

    func filter(for searchText: String?) {
        //let text = searchText?.lowercased() ?? ""
        //filteredTokens = storage.objects.filter { $0.name.lowercased().contains(text) || $0.symbol.lowercased().contains(text) }
        //tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectItem(item: item(for: indexPath), in: self)
    }
}

extension MarketplaceViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filter(for: searchBar.text)
    }
}

extension MarketplaceViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filter(for: searchController.searchBar.text)
    }
}

extension MarketplaceViewController: StatefulViewController {
    func hasContent() -> Bool {
        return items.isEmpty
    }
}
