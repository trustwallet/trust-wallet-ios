// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import RealmSwift
import TrustCore
import PromiseKit

protocol TokensViewModelDelegate: class {
    func refresh()
}

final class TokensViewModel: NSObject {
    let config: Config

    let store: TokensDataStore
    var tokensNetwork: NetworkProtocol
    let tokens: Results<TokenObject>
    var tokensObserver: NotificationToken?
    let transactionStore: TransactionsStorage
    let session: WalletSession
    var headerViewTitle: String {
        guard let coin = session.account.currentAccount.coin else { return "" }
        return CoinViewModel(coin: coin).displayName
    }

    var headerBalance: String {
        return amount ?? "0.00"
    }

    var headerBalanceTextColor: UIColor {
        return Colors.black
    }

    var headerBackgroundColor: UIColor {
        return Colors.veryVeryLightGray
    }

    var headerBalanceFont: UIFont {
        return UIFont.systemFont(ofSize: 28, weight: .medium)
    }

    var title: String {
        return NSLocalizedString("wallet.navigation.title", value: "Wallet", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }

    var footerTitle: String {
        return NSLocalizedString("tokens.footer.label.title", value: "Tokens will appear automagically. Tap + to add manually.", comment: "")
    }

    var footerTextColor: UIColor {
        return Colors.black
    }

    var footerTextFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: .light)
    }

    var all: [TokenViewModel] {
        return Array(tokens).map { token in
            return TokenViewModel(token: token, config: config, store: store, transactionsStore: transactionStore, tokensNetwork: tokensNetwork, session: session)
        }
    }

    weak var delegate: TokensViewModelDelegate?

    init(
        session: WalletSession,
        config: Config = Config(),
        store: TokensDataStore,
        tokensNetwork: NetworkProtocol,
        transactionStore: TransactionsStorage
    ) {
        self.session = session
        self.config = config
        self.store = store
        self.tokensNetwork = tokensNetwork
        self.tokens = store.tokens
        self.transactionStore = transactionStore
        super.init()
    }

    func setTokenObservation(with block: @escaping (RealmCollectionChange<Results<TokenObject>>) -> Void) {
        tokensObserver = tokens.observe(block)
    }

    private var amount: String? {
        let totalAmount = tokens.lazy.flatMap { [weak self] in
            self?.amount(for: $0)
        }.reduce(0, +)
        return CurrencyFormatter.formatter.string(from: NSNumber(value: totalAmount))
    }

    private func amount(for token: TokenObject) -> Double {
        guard let coinTicker = store.coinTicker(for: token) else {
            return 0
        }
        let tokenValue = CurrencyFormatter.plainFormatter.string(from: token.valueBigInt, decimals: token.decimals).doubleValue
        let price = Double(coinTicker.price) ?? 0
        return tokenValue * price
    }

    func numberOfItems(for section: Int) -> Int {
        return tokens.count
    }

    func item(for path: IndexPath) -> TokenObject {
        return tokens[path.row]
    }

    func canEdit(for path: IndexPath) -> Bool {
        return tokens[path.row].isCustom
    }

    func canDisable(for path: IndexPath) -> Bool {
        return true
    }

    func cellViewModel(for path: IndexPath) -> TokenViewCellViewModel {
        let token = tokens[path.row]
        return TokenViewCellViewModel(token: token, ticker: store.coinTicker(for: token), store: transactionStore)
    }

    func updateBalances() {
        let tokens = Array(self.tokens)
        NSLog("updateBalances \(tokens.count)")
        balances(for: tokens)
    }

    private func tokensInfo() {
        firstly {
            tokensNetwork.tokensList(for: session.account.address)
        }.done { [weak self] tokens in
             self?.store.update(tokens: tokens, action: .updateInfo)
        }.catch { error in
            NSLog("tokensInfo \(error)")
        }.finally { [weak self] in
            guard let strongSelf = self else { return }
            let tokens = strongSelf.store.objects
            let enabledTokens = strongSelf.store.enabledObject
            strongSelf.prices(for: tokens)
            strongSelf.balances(for: enabledTokens)
        }
    }

    private func prices(for tokens: [TokenObject]) {
        let prices = tokens.map { TokenPrice(contract: $0.contract, symbol: $0.symbol) }
        firstly {
            tokensNetwork.tickers(with: prices)
        }.done { [weak self] tickers in
            self?.store.saveTickers(tickers: tickers)
        }.catch { error in
            NSLog("prices \(error)")
        }.finally { [weak self] in
            self?.delegate?.refresh()
        }
    }

    private func balances(for tokens: [TokenObject]) {
        let balances: [BalanceNetworkProvider] = tokens.compactMap {
            return TokenViewModel.balance(for: $0, wallet: session.account)
        }
        let operationQueue: OperationQueue = OperationQueue()
        operationQueue.qualityOfService = .background

        let balancesOperations = Array(balances.lazy.map {
            TokenBalanceOperation(balanceProvider: $0, store: self.store)
        })
        operationQueue.addOperations(balancesOperations, waitUntilFinished: false)
    }

    func updatePendingTransactions() {
        //all.forEach { $0.updatePending() }
    }

    func fetch() {
        tokensInfo()
        updatePendingTransactions()
    }

    func invalidateTokensObservation() {
        tokensObserver?.invalidate()
        tokensObserver = nil
    }
}

extension Array where Element: Operation {
    /// Execute block after all operations from the array.
    func onFinish(block: @escaping () -> Void) {
        let doneOperation = BlockOperation(block: block)
        self.forEach { [unowned doneOperation] in
            doneOperation.addDependency($0)

        }
        OperationQueue().addOperation(doneOperation)
    }
}
