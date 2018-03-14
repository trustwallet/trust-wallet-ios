// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import RealmSwift
import TrustKeystore

enum TokenItem {
    case token(TokenObject)
}

class TokensViewModel {
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

    private var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .background
        queue.maxConcurrentOperationCount = 1
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
        guard let tickersSymbol = store.tickers.first(where: { $0.contract == token.contract }) else { return 0 }
        let tokenValue = CurrencyFormatter.plainFormatter.string(from: token.valueBigInt, decimals: token.decimals).doubleValue
        let price = Double(tickersSymbol.price) ?? 0
        return tokenValue * price
    }

    func numberOfItems(for section: Int) -> Int {
        return tokens.count
    }

    func item(for path: IndexPath) -> TokenItem {
        return .token(tokens[path.row])
    }

    func canEdit(for path: IndexPath) -> Bool {
        let token = item(for: path)
        switch token {
        case .token(let token):
            return token.isCustom
        }
    }

    func cellViewModel(for path: IndexPath) -> TokenViewCellViewModel {
        let token = tokens[path.row]
        return TokenViewCellViewModel(token: token, ticker: store.coinTicker(for: token))
    }

    func updateEthBalance(completion: ((_ completed: Bool) -> Void)? = nil) {
        tokensNetwork.ethBalance { result in
            guard let balance = result, let token = self.store.objects.first (where: { $0.name == self.config.server.name }), self.operationQueue.operationCount == 0  else {
                completion?(true)
                return
            }
            self.store.update(token: token, action: .updateValue(balance.value))
            completion?(true)
        }
    }

    private func runOperations() {

        guard operationQueue.operationCount == 0, let chaineToken = self.store.objects.first (where: { $0.name == self.config.server.name }) else {
            return
        }

        let ethBalanceOperation = EthBalanceOperation(network: tokensNetwork)

        let tokensOperation = TokensOperation(network: tokensNetwork, address: address)

        let tokensBalanceOperation = TokensBalanceOperation(network: tokensNetwork, address: address)

        let tokensTickerOperation = TokensTickerOperation(network: tokensNetwork, address: address)

        let tempChaine = TokensDataStore.etherToken(for: config)
        tempChaine.value = chaineToken.value

        operationQueue.addOperation(ethBalanceOperation)

        ethBalanceOperation.completionBlock = { [weak self] in
            guard let strongSelf = self else { return }
            tempChaine.value = ethBalanceOperation.balance.value.description
            tokensOperation.tokens.append(tempChaine)
            strongSelf.operationQueue.addOperation(tokensOperation)
        }

        tokensOperation.completionBlock = { [weak self] in
            guard let strongSelf = self else { return }
            tokensBalanceOperation.tokens = tokensOperation.tokens
            strongSelf.operationQueue.addOperation(tokensBalanceOperation)
        }

        tokensBalanceOperation.completionBlock = { [weak self] in
            guard let strongSelf = self else { return }
            tokensTickerOperation.tokens = tokensBalanceOperation.tokens
            strongSelf.operationQueue.addOperation(tokensTickerOperation)
        }

        tokensTickerOperation.completionBlock = { [weak self] in
            guard let strongSelf = self else { return }
            DispatchQueue.main.async {
                strongSelf.store.tickers = tokensTickerOperation.tickers
                strongSelf.store.add(tokens: tokensTickerOperation.tokens)
            }
        }
    }

    func fetch() {
       runOperations()
    }
}
