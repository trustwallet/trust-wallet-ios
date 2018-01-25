// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StatefulViewController

protocol MarketplaceViewControllerDelegate: class {
    func didSelectItem(item: MarketplaceItem, in viewController: MarketplaceViewController)
}

class MarketplaceViewController: UIViewController {

    let session: WalletSession
    let viewModel = MarketplaceViewModel()
    var items = [MarketplaceItem]() {
        didSet {
            tableView.reloadData()
        }
    }
    weak var delegate: MarketplaceViewControllerDelegate?
    private let trustProvider = TrustProviderFactory.makeProvider()
    let refreshControl = UIRefreshControl()
    let tableView = UITableView(frame: .zero, style: .grouped)

    init(
        session: WalletSession
    ) {
        self.session = session

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = viewModel.title

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(R.nib.marketplaceItemTableViewCell(), forCellReuseIdentifier: R.nib.marketplaceItemTableViewCell.name)
        tableView.separatorStyle = .none
        tableView.separatorInset = .zero
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        view.addSubview(tableView)

        refreshControl.addTarget(self, action: #selector(fetch), for: .valueChanged)
        tableView.addSubview(refreshControl)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

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

        trustProvider.request(.marketplace(chainID: session.config.chainID)) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                do {
                    self.items = try response.map(ArrayResponse<MarketplaceItem>.self).docs
                    self.endLoading(error: nil, completion: nil)
                } catch {
                    self.handleError(error: error)
                }
            case .failure(let error):
                self.handleError(error: error)
            }
            self.refreshControl.endRefreshing()
        }
    }

    func handleError(error: Error) {
        endLoading(error: error, completion: nil)
    }

    func item(for indexPath: IndexPath) -> MarketplaceItem {
        return items[indexPath.row]
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MarketplaceViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.marketplaceItemTableViewCell.name, for: indexPath) as! MarketplaceItemTableViewCell
        cell.viewModel = MarketplaceItemViewModel(item: item(for: indexPath))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension MarketplaceViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelectItem(item: item(for: indexPath), in: self)
    }
}

extension MarketplaceViewController: StatefulViewController {
    func hasContent() -> Bool {
        return !items.isEmpty
    }
}
