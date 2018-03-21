// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import RealmSwift
import TrustKeystore

protocol TokensViewModelDelegate: class {
    func refresh()
}

class TokensViewModel: NSObject {
    let config: Config

    let store: TokensDataStore
    var tokensNetwork: NetworkProtocol
    let tokens: Results<TokenObject>
    var tokensObserver: NotificationToken?
    let address: Address

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

    var hasContent: Bool {
        return !tokens.isEmpty
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

    private var serialOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    private var parallelOperationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        return queue
    }()

    init(
        config: Config = Config(),
        address: Address,
        store: TokensDataStore,
        tokensNetwork: NetworkProtocol
    ) {
        self.config = config
        self.address = address
        self.store = store
        self.tokensNetwork = tokensNetwork
        self.tokens = store.tokens
        super.init()
    }

    func setTokenObservation(with block: @escaping (RealmCollectionChange<Results<TokenObject>>) -> Void) {
        tokensObserver = tokens.observe(block)
    }

    private var amount: String? {
        var totalAmount: Double = 0
        tokens.forEach { token in
            totalAmount += amount(for: token)
        }
        return CurrencyFormatter.formatter.string(from: NSNumber(value: totalAmount))
    }

    private func amount(for token: TokenObject) -> Double {
        guard let tickersSymbol = store.tickers().first(where: { $0.contract == token.contract }) else { return 0 }
        let tokenValue = CurrencyFormatter.plainFormatter.string(from: token.valueBigInt, decimals: token.decimals).doubleValue
        let price = Double(tickersSymbol.price) ?? 0
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

    func cellViewModel(for path: IndexPath) -> TokenViewCellViewModel {
        let token = tokens[path.row]
        return TokenViewCellViewModel(token: token, ticker: store.coinTicker(for: token))
    }

    func updateEthBalance(completion: ((_ completed: Bool) -> Void)? = nil) {
        tokensNetwork.tokenBalance(for: TokensDataStore.etherToken().address) { [weak self] (balance) in
            guard let `self` = self, let balance = balance else {
                completion?(true)
                return
            }
            self.store.update(balances: [TokensDataStore.etherToken().address: balance.value])
            completion?(true)
        }
    }

    private func runOperations() {
        guard serialOperationQueue.operationCount == 0 else {
            self.parallelOperations(for: self.store.enabledObject)
            return
        }

        let tokensOperation = TokensOperation(network: tokensNetwork, address: address)

        serialOperationQueue.addOperation(tokensOperation)

        tokensOperation.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.store.update(tokens: tokensOperation.tokens, action: .updateInfo)
                if let tokens = self?.store.enabledObject {
                    self?.parallelOperations(for: tokens)
                }
            }
        }
    }

    private func parallelOperations(for tokens: [TokenObject]) {
        guard parallelOperationQueue.operationCount == 0, !tokens.isEmpty else {
            return
        }

        let tokensBalanceOperation = TokensBalanceOperation(
            network: tokensNetwork,
            addresses: tokens.map { $0.address }
        )

        tokensBalanceOperation.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.store.update(balances: tokensBalanceOperation.balances)
            }
        }

        let tokensTickerOperation = TokensTickerOperation(network: tokensNetwork, tokenPrices: tokens.map { TokenPrice(contract: $0.contract, symbol: $0.symbol) })

        tokensTickerOperation.completionBlock = { [weak self] in
            self?.store.saveTickers(tickers: tokensTickerOperation.tickers)
            DispatchQueue.main.async {
                self?.delegate?.refresh()
            }
        }

        parallelOperationQueue.addOperations([tokensBalanceOperation, tokensTickerOperation], waitUntilFinished: false)
    }

    func fetch() {
        updateEthBalance()
        runOperations()
    }

    func cancelOperations() {
        tokensObserver = nil
        serialOperationQueue.cancelAllOperations()
        parallelOperationQueue.cancelAllOperations()
    }
}
