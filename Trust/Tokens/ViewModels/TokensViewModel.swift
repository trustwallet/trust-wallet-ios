// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import RealmSwift
import TrustCore
import PromiseKit

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

    func canDisable(for path: IndexPath) -> Bool {
        return item(for: path) != TokensDataStore.etherToken()
    }

    func cellViewModel(for path: IndexPath) -> TokenViewCellViewModel {
        let token = tokens[path.row]
        return TokenViewCellViewModel(token: token, ticker: store.coinTicker(for: token))
    }

    func updateEthBalance() {
        firstly {
            tokensNetwork.ethBalance()
        }.done { [weak self] balance in
            self?.store.update(balances: [TokensDataStore.etherToken().address: balance.value])
        }.catch { error in
            print(error)
        }
    }

    private func requests() {
        firstly {
            tokensNetwork.ethBalance()
        }.done {  balance in
            self.store.update(balances: [TokensDataStore.etherToken().address: balance.value])
        }.then { _ in
            self.tokensNetwork.tokensList(for: self.address)
        }.done { tokens in
            self.store.update(tokens: tokens, action: .updateInfo)
        }.catch { error in
            print(error)
        }.finally {
              
        }
    }

    private func parallelOperations(for tokens: [TokenObject]) {

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

    }

    func fetch() {
        requests()
    }

    func invalidateTokensObservation() {
        tokensObserver?.invalidate()
        tokensObserver = nil
    }
}
