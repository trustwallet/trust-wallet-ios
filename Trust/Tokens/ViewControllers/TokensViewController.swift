// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StatefulViewController
import Result

protocol TokensViewControllerDelegate: class {
    func didSelect(token: Token, in viewController: UIViewController)
}

class TokensViewController: UIViewController {

    private lazy var dataStore: TokensDataStore = {
        return .init(account: self.account)
    }()

    var viewModel: TokensViewModel = TokensViewModel(tokens: [])
    let account: Account
    let tableView: UITableView
    let refreshControl = UIRefreshControl()
    weak var delegate: TokensViewControllerDelegate?

    init(
        account: Account
    ) {
        self.account = account
        tableView = UITableView(frame: .zero, style: .plain)

        super.init(nibName: nil, bundle: nil)

        dataStore.delegate = self

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.rowHeight = 72
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])

        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)

        errorView = ErrorView(onRetry: fetch)
        loadingView = LoadingView()
        emptyView = EmptyView(
            title: NSLocalizedString("emptyView.noTokens", value: "You haven't received any tokens yet!", comment: ""),
            onRetry: fetch
        )

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetch()
    }

    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch()
    }

    func fetch() {
        dataStore.fetch()
        startLoading()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TokensViewController: StatefulViewController {
    func hasContent() -> Bool {
        return viewModel.hasContent
    }
}

extension TokensViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let token = viewModel.item(for: indexPath.row, section: indexPath.section)
        delegate?.didSelect(token: token, in: self)
    }
}

extension TokensViewController: TokensDataStoreDelegate {
    func didUpdate(result: Result<TokensViewModel, TokenError>) {
        switch result {
        case .success(let viewModel):
            self.viewModel = viewModel
            endLoading()
        case .failure(let error):
            endLoading(error: error)
        }
        tableView.reloadData()

        if refreshControl.isRefreshing {
            refreshControl.endRefreshing()
        }
    }
}

extension TokensViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let token = viewModel.item(for: indexPath.row, section: indexPath.section)
        let cell = TokenViewCell(style: .default, reuseIdentifier: TokenViewCell.identifier)
        cell.configure(viewModel: .init(token: token))
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }
}
