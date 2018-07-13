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
    var tickers: [CoinTicker]
    var tokensObserver: NotificationToken?
    let wallet: WalletInfo
    let transactionStore: TransactionsStorage
    private var calculationProcessing = false

    var headerViewTitle: String {
        return "Ethereum (ETH)"
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

    weak var delegate: TokensViewModelDelegate?

    init(
        config: Config = Config(),
        wallet: WalletInfo,
        store: TokensDataStore,
        tokensNetwork: NetworkProtocol,
        transactionStore: TransactionsStorage
    ) {
        self.config = config
        self.wallet = wallet
        self.store = store
        self.tokensNetwork = tokensNetwork
        self.tokens = store.tokens
        self.transactionStore = transactionStore
        self.tickers = store.preparedTickres()
        super.init()
    }

    func setTokenObservation(with block: @escaping (RealmCollectionChange<Results<TokenObject>>) -> Void) {
        tokensObserver = tokens.observe(block)
    }

    func amount(completion: @escaping (String?) -> Void) {
        guard !calculationProcessing else { return }
        calculationProcessing = true
        store.tokensQueue.async { [weak self] in
           guard let strongSelf = self else {
                completion( CurrencyFormatter.formatter.string(from: NSNumber(value: TokenObject.DEFAULT_BALANCE)))
                return
           }
           let realm = try! Realm(configuration: strongSelf.store.realm.configuration)
           let tokens = realm.objects(TokenObject.self)
           let tickers = realm.objects(CoinTicker.self)

            let totalAmount = tokens.lazy.flatMap {
                let token = $0
                guard let ticker = tickers.first(where: {
                    return $0.key == CoinTickerKeyMaker.makePrimaryKey(symbol: $0.symbol, contract: token.address, currencyKey: $0.tickersKey)
                }) else { return .none }
                let amount = CurrencyFormatter.plainFormatter.string(from: $0.valueBigInt, decimals: $0.decimals).doubleValue
                let price = Double(ticker.price) ?? 0
                return amount * price
            }.reduce(0.0, +)

            DispatchQueue.main.async {
                self?.calculationProcessing = false
                completion(CurrencyFormatter.formatter.string(from: NSNumber(value: totalAmount)))
            }
        }
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
        return item(for: path) != TokensDataStore.etherToken()
    }

    func cellViewModel(for path: IndexPath) -> TokenViewCellViewModel {
        let token = tokens[path.row]
        var ticker: CoinTicker? = nil
        if tickers.indices.contains(path.row) {
            ticker = tickers[path.row]
        }
        return TokenViewCellViewModel(token: token, ticker: ticker, store: transactionStore)
    }

    func updateEthBalance() {
        firstly {
            tokensNetwork.ethBalance()
        }.done { [weak self] balance in
            self?.store.update(balances: [TokensDataStore.etherToken().address: balance.value])
        }.catch { error in
           NSLog("updateEthBalance \(error)")
        }
    }

    func tokensInfo() {
        firstly {
            tokensNetwork.tokensList(for: wallet.address)
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
            guard let strongSelf = self else { return }
            strongSelf.store.saveTickers(tickers: tickers)
            strongSelf.tickers = strongSelf.store.preparedTickres()
        }.catch { error in
            NSLog("prices \(error)")
        }.finally { [weak self] in
            self?.delegate?.refresh()
        }
    }

    private func balances(for tokens: [TokenObject]) {

        let operationQueue: OperationQueue = OperationQueue()
        operationQueue.qualityOfService = .background

        let balancesOperations = Array(tokens.lazy.map { TokenBalanceOperation(network: self.tokensNetwork, address: $0.address, store: self.store) })
        operationQueue.addOperations(balancesOperations, waitUntilFinished: false)
    }

    func updatePendingTransactions() {
        let transactions = transactionStore.pendingObjects
        for transaction in transactions {
            tokensNetwork.update(for: transaction) { result in
                switch result {
                case .success(let transaction, let state):
                    self.transactionStore.update(state: state, for: transaction)
                case .failure: break
                }
            }
        }
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
