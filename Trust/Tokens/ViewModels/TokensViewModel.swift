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
    var tokensNetwork: TokensNetworkProtocol
    let tokens: Results<TokenObject>
    var tokensObserver: NotificationToken?
    let address: Address

    var headerBalance: String? {
        return amount
    }

    var headerBalanceTextColor: UIColor {
        return Colors.black
    }

    var headerBackgroundColor: UIColor {
        return .white
    }

    var headerBalanceFont: UIFont {
        return UIFont.systemFont(ofSize: 26, weight: .medium)
    }

    var title: String {
        return NSLocalizedString("tokens.navigation.title", value: "Tokens", comment: "")
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

    private var serailOperationQueue: OperationQueue = {
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
        tokensNetwork: TokensNetworkProtocol
    ) {
        self.config = config
        self.address = address
        self.store = store
        self.tokensNetwork = tokensNetwork
        self.tokens = store.tokens
        super.init()
        updateEthBalance { [weak self] _ in
            self?.runOperations()
        }
    }

    func setTokenObservation(with block: @escaping (RealmCollectionChange<Results<TokenObject>>) -> Void) {
        tokensObserver = tokens.observe(block)
    }

    private var amount: String? {
        var totalAmount: Double = 0
        tokens.forEach { token in
            totalAmount += amount(for: token)
        }
        guard totalAmount != 0 else { return "--" }
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
        tokensNetwork.ethBalance { result in
            guard let balance = result, let token = self.store.objects.first (where: { $0.name == self.config.server.name }), self.serailOperationQueue.operationCount == 0  else {
                completion?(true)
                return
            }
            self.store.update(tokens: [token], action: .updateValue(balance.value))
            completion?(true)
        }
    }

    private func runOperations() {
        guard serailOperationQueue.operationCount == 0, let chaineToken = self.store.objects.first (where: { $0.name == self.config.server.name }), parallelOperationQueue.operationCount == 0 else {
            return
        }

        let ethBalanceOperation = EthBalanceOperation(network: tokensNetwork)

        let tokensOperation = TokensOperation(network: tokensNetwork, address: address)

        let tempChaine = TokensDataStore.etherToken(for: config)
        tempChaine.value = chaineToken.value

        serailOperationQueue.addOperation(ethBalanceOperation)

        ethBalanceOperation.completionBlock = { [weak self] in
            tempChaine.value = ethBalanceOperation.balance.value.description
            tokensOperation.tokens.append(tempChaine)
            self?.serailOperationQueue.addOperation(tokensOperation)
        }

        tokensOperation.completionBlock = { [weak self] in
            self?.parallelOperations(for: tokensOperation.tokens)
            DispatchQueue.main.async {
                self?.store.update(tokens: tokensOperation.tokens, action: .updateInfo)
            }
        }
    }

    private func parallelOperations(for tokens: [TokenObject]) {
        let tokensBalanceOperation = TokensBalanceOperation(network: tokensNetwork, address: address)
        tokensBalanceOperation.tokens = tokens

        tokensBalanceOperation.completionBlock = { [weak self] in
            DispatchQueue.main.async {
                self?.store.update(tokens: tokensBalanceOperation.tokens, action: .updateBalance)
            }
        }

        let tokensTickerOperation = TokensTickerOperation(network: tokensNetwork, address: address)
        tokensTickerOperation.tokens = tokens

        tokensTickerOperation.completionBlock = { [weak self] in
            self?.store.saveTickers(tickers: tokensTickerOperation.tickers)
            DispatchQueue.main.async {
                self?.delegate?.refresh()
            }
        }

        parallelOperationQueue.addOperations([tokensBalanceOperation, tokensTickerOperation], waitUntilFinished: true)
    }

    func fetch() {
       runOperations()
    }
}
