// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import APIKit
import JSONRPCKit
import StatefulViewController
import Result

protocol TransactionsViewControllerDelegate: class {
    func didPressSend(in viewController: TransactionsViewController)
    func didPressRequest(in viewController: TransactionsViewController)
    func didPressTransaction(transaction: Transaction, in viewController: TransactionsViewController)
    func didPressTokens(in viewController: TransactionsViewController)
    func didPressDeposit(for account: Account, in viewController: TransactionsViewController)
}

class TransactionsViewController: UIViewController {

    var viewModel: TransactionsViewModel

    let account: Account
    let tableView = UITableView(frame: .zero, style: .plain)
    let refreshControl = UIRefreshControl()

    lazy var titleView: BalanceTitleView = {
        return BalanceTitleView.make(from: self.session, .ether(destination: .none))
    }()

    weak var delegate: TransactionsViewControllerDelegate?
    let dataCoordinator: TransactionDataCoordinator
    let session: WalletSession

    lazy var footerView: TransactionsFooterView = {
        let footerView = TransactionsFooterView(frame: .zero)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.requestButton.addTarget(self, action: #selector(request), for: .touchUpInside)
        footerView.sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        return footerView
    }()

    init(
        account: Account,
        dataCoordinator: TransactionDataCoordinator,
        session: WalletSession,
        viewModel: TransactionsViewModel = TransactionsViewModel(transactions: [])
    ) {
        self.account = account
        self.dataCoordinator = dataCoordinator
        self.session = session
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = viewModel.backgroundColor
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.rowHeight = 68
        view.addSubview(tableView)
        view.addSubview(footerView)

        let tokensButton = Button(size: .extraLarge, style: .borderless)
        tokensButton.setTitle(NSLocalizedString("Transactions.ShowTokens", value: "Show my tokens", comment: ""), for: .normal)
        tokensButton.contentEdgeInsets = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        tokensButton.setTitleColor(Colors.black, for: .normal)
        tokensButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        tokensButton.sizeToFit()
        tokensButton.addTarget(self, action: #selector(showTokens), for: .touchUpInside)

        tableView.tableHeaderView = tokensButton

        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            footerView.trailingAnchor.constraint(equalTo: view.layoutGuide.trailingAnchor),
            footerView.leadingAnchor.constraint(equalTo: view.layoutGuide.leadingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.layoutGuide.bottomAnchor),
        ])

        dataCoordinator.delegate = self
        dataCoordinator.start()

        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)

        //TODO: Find a way to fix hardcoded 32px value. Use bottom safe inset instead.
        let insets = UIEdgeInsets(top: 130, left: 0, bottom: ButtonSize.extraLarge.height + 50, right: 0)

        errorView = ErrorView(insets: insets, onRetry: fetch)
        loadingView = LoadingView(insets: insets)
        emptyView = {
            let view = TransactionsEmptyView(
                insets: insets,
                onDeposit: { [unowned self] in self.showDeposit() }
            )
            view.isDepositAvailable = viewModel.isBuyActionAvailable
            return view
        }()

        navigationItem.titleView = titleView
        titleView.configure(viewModel: BalanceViewModel())
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetch()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch()
    }

    func fetch() {
        startLoading()
        fetchBalance()
    }

    func fetchBalance() {
        session.refresh(.balance)
        dataCoordinator.fetch()
    }

    @objc func send() {
        delegate?.didPressSend(in: self)
    }

    @objc func request() {
        delegate?.didPressRequest(in: self)
    }

    @objc func showTokens() {
        delegate?.didPressTokens(in: self)
    }

    func showDeposit() {
        delegate?.didPressDeposit(for: account, in: self)
    }

    func configure(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TransactionsViewController: StatefulViewController {
    func hasContent() -> Bool {
        return viewModel.numberOfSections > 0
    }
}

extension TransactionsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true )
        delegate?.didPressTransaction(transaction: viewModel.item(for: indexPath.row, section: indexPath.section), in: self)
    }
}

extension TransactionsViewController: TransactionDataCoordinatorDelegate {
    func didUpdate(result: Result<[Transaction], TransactionError>) {
        switch result {
        case .success(let items):
        let viewModel = TransactionsViewModel(transactions: items)
            configure(viewModel: viewModel)
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

extension TransactionsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let transaction = viewModel.item(for: indexPath.row, section: indexPath.section)
        let cell = TransactionViewCell(style: .default, reuseIdentifier: TransactionViewCell.identifier)
        cell.configure(viewModel: .init(
                transaction: transaction,
                chainState: session.chainState
            )
        )
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(in: section)
    }

    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.contentView.backgroundColor = viewModel.headerBackgroundColor
        header.textLabel?.textColor = viewModel.headerTitleTextColor
        header.textLabel?.font = viewModel.headerTitleFont
        header.layer.addBorder(edge: .top, color: viewModel.headerBorderColor, thickness: 0.5)
        header.layer.addBorder(edge: .bottom, color: viewModel.headerBorderColor, thickness: 0.5)
    }
}
