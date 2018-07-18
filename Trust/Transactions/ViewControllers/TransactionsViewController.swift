// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import APIKit
import JSONRPCKit
import StatefulViewController
import Result
import TrustCore
import RealmSwift
import TrustKeystore

protocol TransactionsViewControllerDelegate: class {
    func didPressTransaction(transaction: Transaction, in viewController: TransactionsViewController)
}

class TransactionsViewController: UIViewController {

    var viewModel: TransactionsViewModel
    let tableView = TransactionsTableView()
    let refreshControl = UIRefreshControl()
    weak var delegate: TransactionsViewControllerDelegate?
    let session: WalletSession
    let insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

    init(
        session: WalletSession,
        viewModel: TransactionsViewModel
    ) {
        self.session = session
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = TransactionsViewModel.backgroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        tableView.register(TransactionViewCell.self, forCellReuseIdentifier: TransactionViewCell.identifier)

        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        refreshControl.backgroundColor = TransactionsViewModel.backgroundColor
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)

        errorView = ErrorView(insets: insets, onRetry: { [weak self] in
            self?.startLoading()
            self?.viewModel.fetch()
        })
        loadingView = LoadingView(insets: insets)
        emptyView = {
            let view = TransactionsEmptyView(
                insets: insets,
                onRetry: { [unowned self] in
                    self.pullToRefresh()
                }
            )
            return view
        }()

        navigationItem.title = viewModel.title
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
        startLoading()
        viewModel.fetch { [weak self] in
            self?.endLoading()
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TransactionsViewController: StatefulViewController {
    func hasContent() -> Bool {
        return viewModel.hasContent
    }
}

extension TransactionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true )
        delegate?.didPressTransaction(transaction: viewModel.item(for: indexPath.row, section: indexPath.section), in: self)
    }
}

extension TransactionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionViewCell.identifier, for: indexPath) as! TransactionViewCell
        cell.configure(viewModel: viewModel.cellViewModel(for: indexPath))
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewModel.hederView(for: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return StyleLayout.TableView.heightForHeaderInSection
    }
}

extension TransactionsViewController: Scrollable {
    func scrollOnTop() {
        tableView.scrollOnTop()
    }
}
