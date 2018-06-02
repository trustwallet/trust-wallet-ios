// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import APIKit
import JSONRPCKit
import StatefulViewController
import Result
import TrustCore
import RealmSwift

protocol TransactionsViewControllerDelegate: class {
    func didPressSend(in viewController: TransactionsViewController)
    func didPressRequest(in viewController: TransactionsViewController)
    func didPressTransaction(transaction: Transaction, in viewController: TransactionsViewController)
    func didPressDeposit(for account: Wallet, sender: UIView, in viewController: TransactionsViewController)
}

class TransactionsViewController: UIViewController {

    var viewModel: TransactionsViewModel
    let account: Wallet
    let tableView = TransactionsTableView()
    let refreshControl = UIRefreshControl()
    weak var delegate: TransactionsViewControllerDelegate?
    var timer: Timer?
    var updateTransactionsTimer: Timer?
    let session: WalletSession
    let insets = UIEdgeInsets(top: 130, left: 0, bottom: ButtonSize.extraLarge.height + 84, right: 0)

    init(
        account: Wallet,
        session: WalletSession,
        viewModel: TransactionsViewModel
    ) {
        self.account = account
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
                onDeposit: { [unowned self] sender in
                    self.showDeposit(sender)
                }
            )
            view.isDepositAvailable = viewModel.isBuyActionAvailable
            return view
        }()

        navigationItem.title = viewModel.title
        runScheduledTimers()
        NotificationCenter.default.addObserver(self, selector: #selector(TransactionsViewController.stopTimers), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TransactionsViewController.restartTimers), name: .UIApplicationDidBecomeActive, object: nil)

        transactionsObservation()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshControl.endRefreshing()
        fetch()
    }

    private func transactionsObservation() {
        viewModel.transactionsUpdateObservation { [weak self] in
            guard let `self` = self else { return }
            self.tableView.reloadData()
            self.endLoading()
            self.refreshControl.endRefreshing()
            self.tabBarItem.badgeValue = self.viewModel.badgeValue
        }
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
        }
    }

    @objc func send() {
        delegate?.didPressSend(in: self)
    }

    @objc func request() {
        delegate?.didPressRequest(in: self)
    }

    func showDeposit(_ sender: UIButton) {
        delegate?.didPressDeposit(for: account, sender: sender, in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func stopTimers() {
        timer?.invalidate()
        timer = nil
        updateTransactionsTimer?.invalidate()
        updateTransactionsTimer = nil
        viewModel.invalidateTransactionsObservation()
    }

    @objc func restartTimers() {
        runScheduledTimers()
        transactionsObservation()
    }

    private func runScheduledTimers() {
        guard timer == nil, updateTransactionsTimer == nil else {
            return
        }
        timer = Timer.scheduledTimer(timeInterval: 5, target: BlockOperation { [weak self] in
            self?.viewModel.fetchPending()
        }, selector: #selector(Operation.main), userInfo: nil, repeats: true)
        updateTransactionsTimer = Timer.scheduledTimer(timeInterval: 15, target: BlockOperation { [weak self] in
            self?.viewModel.fetchTransactions()
        }, selector: #selector(Operation.main), userInfo: nil, repeats: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        viewModel.invalidateTransactionsObservation()
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
