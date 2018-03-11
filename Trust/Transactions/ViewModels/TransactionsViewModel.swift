// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import RealmSwift

struct TransactionsViewModel {

    static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var backgroundColor: UIColor {
        return .white
    }

    var headerBackgroundColor: UIColor {
        return UIColor(hex: "fafafa")
    }

    var headerTitleTextColor: UIColor {
        return UIColor(hex: "555357")
    }

    var headerTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.medium)
    }

    var headerBorderColor: UIColor {
        return UIColor(hex: "e1e1e1")
    }

    var isBuyActionAvailable: Bool {
        switch config.server {
        case .main, .kovan, .classic, .callisto, .ropsten, .rinkeby, .poa, .sokol, .custom: return false
        }
    }

    var numberOfSections: Int {
        return transactions.count
    }

    private var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    var transactions: Results<TransactionCategory>

    var tokensObserver: NotificationToken?

    let config: Config

    let network: TransactionsNetwork

    let storage: TransactionsStorage

    let session: WalletSession

    init(
        network: TransactionsNetwork,
        storage: TransactionsStorage,
        session: WalletSession,
        config: Config = Config()
    ) {
        self.network = network
        self.storage = storage
        self.session = session
        self.config = config
        self.transactions = storage.transactionsCategory
    }

    mutating func setTransactionsObservation(with block: @escaping (RealmCollectionChange<Results<TransactionCategory>>) -> Void) {
        tokensObserver = transactions.observe(block)
    }

    func numberOfItems(for section: Int) -> Int {
        return transactions[section].transactions.count
    }

    func item(for row: Int, section: Int) -> Transaction {
        return transactions[section].transactions[row]
    }

    func titleForHeader(in section: Int) -> String {
        let value = transactions[section].title
        let date = TransactionsViewModel.formatter.date(from: value)!
        if NSCalendar.current.isDateInToday(date) {
            return NSLocalizedString("Today", value: "Today", comment: "")
        }
        if NSCalendar.current.isDateInYesterday(date) {
            return NSLocalizedString("Yesterday", value: "Yesterday", comment: "")
        }
        return value
    }

    func hederView(for section: Int) -> UIView {
        let conteiner = UIView()
        conteiner.backgroundColor = self.headerBackgroundColor
        let title = UILabel()
        title.text = self.titleForHeader(in: section)
        title.sizeToFit()
        title.textColor = self.headerTitleTextColor
        title.font = self.headerTitleFont
        conteiner.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        let horConstraint = NSLayoutConstraint(item: title, attribute: .centerX, relatedBy: .equal, toItem: conteiner, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let verConstraint = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: conteiner, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let leftConstraint = NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: conteiner, attribute: .left, multiplier: 1.0, constant: 20.0)
        conteiner.addConstraints([horConstraint, verConstraint, leftConstraint])
        return conteiner
    }

    func cellViewModel(for indexPath: IndexPath) -> TransactionCellViewModel {
        return TransactionCellViewModel(transaction: transactions[indexPath.section].transactions[indexPath.row], config: config, chainState: session.chainState, currentWallet: session.account)
    }

    func statBlock() -> Int {
        guard let transaction = storage.completedObjects.first else { return 1 }
        return transaction.blockNumber - 2000
    }

    mutating func fetch() {
        initialFetch()
        fetchTransactions()
        fetchPending()
    }

    private func initialFetch() {
        if TransactionsTracker(sessionID: session.sessionID).fetchingState != .done {
            let operation = TransactionOperation(network: network, session: session)
            operationQueue.addOperation(operation)
            operation.completionBlock = {
                DispatchQueue.main.async {
                    self.storage.add(operation.transactionsHistory)
                }
            }
        }
    }

    func fetchTransactions() {
        self.network.transactions(for: session.account.address, startBlock: statBlock(), page: 0) { result in
            guard let transactions = result.0 else { return }
            self.storage.add(transactions)
        }
    }

    func addSentTransaction(_ transaction: SentTransaction) {
        let transaction = SentTransaction.from(from: session.account.address, transaction: transaction)
        storage.add([transaction])
    }

    func fetchPending() {
        self.storage.transactions.forEach {
            self.network.update(for: $0, completion: { result in
                switch result.1 {
                case .deleted:
                    self.storage.delete([result.0])
                default:
                    self.storage.update(state: result.1, for: result.0)
                }
            })
        }
    }

    mutating func filterTransactions(by occurrence: String?) {
        guard let text = occurrence, !text.isEmpty else {
            self.transactions = storage.transactionsCategory
            return
        }
        let subpredicates = ["title","transactions.id","transactions.from","transactions.to","transactions.value","transactions.localizedOperations.name","transactions.localizedOperations.symbol","transactions.localizedOperations.contract"].map { property -> NSPredicate in
            if property.contains("transactions") {
                return NSPredicate(format: "ANY %K CONTAINS[cd] %@", property, text)
            }
            return NSPredicate(format: "%K CONTAINS[cd] %@", property, text)
        }
        let predicate = NSCompoundPredicate(orPredicateWithSubpredicates: subpredicates)
        self.transactions = storage.transactionsCategory.filter(predicate)
    }
}
