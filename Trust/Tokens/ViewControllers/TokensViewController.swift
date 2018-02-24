// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StatefulViewController
import Result
import TrustKeystore

protocol TokensViewControllerDelegate: class {
    func didPressAddToken( in viewController: UIViewController)
    func didSelect(token: TokenItem, in viewController: UIViewController)
    func didDelete(token: TokenItem, in viewController: UIViewController)
    func didEdit(token: TokenItem, in viewController: UIViewController)
}

class TokensViewController: UIViewController {

    private let dataStore: TokensDataStore

    var viewModel: TokensViewModel = TokensViewModel(tokens: [], nonFungibleTokens: [], tickers: .none) {
        didSet {
            refreshView(viewModel: viewModel)
        }
    }
    lazy var header: TokensHeaderView = {
        let header = TokensHeaderView(frame: .zero)
        header.amountLabel.text = viewModel.headerBalance ?? "-"
        header.amountLabel.textColor = viewModel.headerBalanceTextColor
        header.backgroundColor = viewModel.headerBackgroundColor
        header.amountLabel.font = viewModel.headerBalanceFont
        header.frame.size = header.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        return header
    }()
    lazy var footer: TokensFooterView = {
        let footer = TokensFooterView(frame: .zero)
        footer.textLabel.text = viewModel.footerTitle
        footer.textLabel.font = viewModel.footerTextFont
        footer.textLabel.textColor = viewModel.footerTextColor
        footer.frame.size = footer.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        footer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(missingToken))
        )
        return footer
    }()
    let account: Wallet
    let tableView: UITableView
    let refreshControl = UIRefreshControl()
    weak var delegate: TokensViewControllerDelegate?

    init(
        account: Wallet,
        dataStore: TokensDataStore
    ) {
        self.account = account
        self.dataStore = dataStore
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
        dataStore.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
        tableView.register(TokenViewCell.self, forCellReuseIdentifier: TokenViewCell.identifier)
        tableView.register(R.nib.nonFungibleTokenViewCell(), forCellReuseIdentifier: R.nib.nonFungibleTokenViewCell.name)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        errorView = ErrorView(onRetry: { [weak self] in
            self?.startLoading()
            self?.dataStore.fetch()
        })
        loadingView = LoadingView()
        emptyView = EmptyView(
            title: NSLocalizedString("emptyView.noTokens.label.title", value: "You haven't received any tokens yet!", comment: ""),
            onRetry: { [weak self] in
                self?.startLoading()
                self?.dataStore.fetch()
        })
        tableView.tableHeaderView = header
        tableView.tableFooterView = footer
        refreshView(viewModel: viewModel)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.applyTintAdjustment()
        fetch()
    }
    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch()
    }

    func fetch() {
        self.startLoading()
        self.dataStore.fetch()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshView(viewModel: TokensViewModel) {
        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
        header.amountLabel.text = viewModel.headerBalance
        footer.textLabel.text = viewModel.footerTitle
    }

    @objc func missingToken() {
        delegate?.didPressAddToken(in: self)
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

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.canEdit(for: indexPath.row, section: indexPath.section)
    }

    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {

        if !viewModel.canEdit(for: indexPath.row, section: indexPath.section) {
            return []
        }

        let token = viewModel.item(for: indexPath.row, section: indexPath.section)
        let delete = UITableViewRowAction(style: .destructive, title: NSLocalizedString("Delete", value: "Delete", comment: "")) {[unowned self] (_, _) in
            self.delegate?.didDelete(token: token, in: self)
        }
        let edit = UITableViewRowAction(style: .normal, title: NSLocalizedString("Edit", value: "Edit", comment: "")) {[unowned self] (_, _) in
            self.delegate?.didEdit(token: token, in: self)
        }
        return [delete, edit]
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
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
        switch token {
        case .token(let token):
            let cell = tableView.dequeueReusableCell(withIdentifier: TokenViewCell.identifier, for: indexPath) as! TokenViewCell
            cell.configure(
                viewModel: .init(
                    token: token,
                    ticker: viewModel.ticker(for: token)
                )
            )
            return cell
        case .nonFungibleTokens(let token):
            let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.nonFungibleTokenViewCell.name, for: indexPath) as! NonFungibleTokenViewCell
            cell.configure(viewModel: .init(token: token))
            return cell
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }
}
