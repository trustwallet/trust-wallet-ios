// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StatefulViewController
import Result
import TrustKeystore
import RealmSwift

protocol TokensViewControllerDelegate: class {
    func didPressAddToken( in viewController: UIViewController)
    func didSelect(token: TokenItem, in viewController: UIViewController)
    func didDelete(token: TokenItem, in viewController: UIViewController)
    func didEdit(token: TokenItem, in viewController: UIViewController)
}

class TokensViewController: UIViewController {
    private let dataStore: TokensDataStore
    fileprivate var viewModel: TokensViewModel
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
    let tableView: UITableView
    let refreshControl = UIRefreshControl()
    weak var delegate: TokensViewControllerDelegate?

    init(
        dataStore: TokensDataStore
    ) {
        self.dataStore = dataStore
        self.viewModel = TokensViewModel(realmDataStore: dataStore)
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
        self.tokensObservation()
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
        refreshHeaderAndFooterView()
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

    func refreshHeaderAndFooterView() {
        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
        header.amountLabel.text = viewModel.headerBalance
        footer.textLabel.text = viewModel.footerTitle
    }

    @objc func missingToken() {
        delegate?.didPressAddToken(in: self)
    }
    /// Token observation.
    private func tokensObservation() {
        viewModel.setTokenObservation { [weak self] (changes: RealmCollectionChange) in
            guard let strongSelf = self else { return }
            let tableView = strongSelf.tableView
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                for row in modifications {
                    let indexPath = IndexPath(row: row, section: 0)
                    let model = strongSelf.viewModel.cellViewModel(for: indexPath)
                    if let cell = tableView.cellForRow(at: indexPath) as? TokenViewCell {
                        cell.configure(viewModel: model)
                    }
                }
                tableView.endUpdates()
                self?.endLoading()
            case .error(let error):
                self?.endLoading(animated: true, error: error, completion: nil)
            }
            self?.refreshHeaderAndFooterView()
        }
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
        let token = viewModel.item(for: indexPath)
        delegate?.didSelect(token: token, in: self)
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.canEdit(for: indexPath)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard !viewModel.canEdit(for: indexPath) else {
            return []
        }
        let token = viewModel.item(for: indexPath)
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
extension TokensViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TokenViewCell.identifier, for: indexPath) as! TokenViewCell
        cell.configure(viewModel: viewModel.cellViewModel(for: indexPath))
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tokens.count
    }
}
