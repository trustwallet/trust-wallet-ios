// Copyright SIX DAY LLC, Inc. All rights reserved.

import UIKit
import APIKit
import JSONRPCKit
import StatefulViewController

protocol TransactionsViewControllerDelegate: class {
    func didPressSend(for account: Account, in viewController: TransactionsViewController)
    func didPressRequest(for account: Account, in viewController: TransactionsViewController)
    func didPressTransaction(transaction: Transaction, in viewController: TransactionsViewController)
}

class TransactionsViewController: UIViewController {
    
    var viewModel: TransactionsViewModel!
    
    private lazy var dataStore: TransactionDataStore = {
        return .init(account: self.account)
    }()
    
    let account: Account
    let tableView: UITableView
    let sendButton: UIButton
    let requestButton: UIButton
    let refreshControl = UIRefreshControl()
    
    lazy var titleView: BalanceTitleView = {
        return BalanceTitleView(frame: .zero)
    }()
    
    weak var delegate: TransactionsViewControllerDelegate?
    
    init(account: Account) {
        self.account = account
        tableView = UITableView(frame: .zero, style: .plain)
        sendButton = Button(size: .extraLarge, style: .squared)
        requestButton = Button(size: .extraLarge, style: .squared)
        
        viewModel = TransactionsViewModel(transactions: [])
        
        super.init(nibName: nil, bundle: nil)
        
        dataStore.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
        sendButton.setTitle("Send", for: .normal)
        sendButton.backgroundColor = Colors.blue
        
        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.addTarget(self, action: #selector(request), for: .touchUpInside)
        requestButton.backgroundColor = Colors.blue
        requestButton.setTitle("Request", for: .normal)
        
        let stackView = UIStackView(arrangedSubviews: [
            sendButton,
            requestButton
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: stackView.topAnchor),
            
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        
        errorView = {
            let view = ErrorView()
            view.onRetry = fetch
            return view
        }()

        loadingView = {
            let view = LoadingView()
            return view
        }()

        emptyView = {
            let view = EmptyView()
            view.onRetry = fetch
            return view
        }()
        
        navigationItem.titleView = titleView
        
        setTitlte(text: viewModel.title)
        view.backgroundColor = viewModel.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        fetch()
    }
    
    func setTitlte(text: String) {
        titleView.title = text
    }
    
    func configureBalance(_ balance: Balance) {
        let viewModel = BalanceViewModel(balance: balance)
        setTitlte(text: viewModel.title)
    }
    
    func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch()
    }
    
    func fetch() {
        dataStore.fetch()
        startLoading()
        fetchBalance()
    }
    
    func fetchBalance() {
        
        let request = EtherServiceRequest(batch: BatchFactory().create(BalanceRequest(address: account.address)))
        Session.send(request) { [weak self] result in
            switch result {
            case .success(let balance):
                self?.configureBalance(balance)
                NSLog("balance \(balance) for account \(self?.account.address ?? "")")
            case .failure(let error):
                NSLog("fetchBalance error \(error)")
            }
        }
    }
    
    @objc func send() {
        delegate?.didPressSend(for: account, in: self)
    }
    
    @objc func request() {
        delegate?.didPressRequest(for: account, in: self)
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

extension TransactionsViewController: TransactionDataStoreDelegate {
    func didFail(with error: Error, viewModel: TransactionsViewModel) {
        endLoading(error: error)
    }
    
    func didUpdate(viewModel: TransactionsViewModel) {
        self.viewModel = viewModel
        tableView.reloadData()
        endLoading()
        
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
        cell.configure(viewModel: .init(transaction: transaction))
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(in: section)
    }
}

