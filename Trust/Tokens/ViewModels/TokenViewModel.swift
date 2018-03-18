// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt
import RealmSwift

struct TokenViewModel {

    private let shortFormatter = EtherNumberFormatter.short
    private let config: Config
    private let store: TokensDataStore
    private var tokensNetwork: TokensNetworkProtocol
    fileprivate var notificationToken: NotificationToken?

    let token: TokenObject

    var title: String {
        return token.displayName
    }

    var imageURL: URL? {
        return token.imageURL
    }

    var imagePlaceholder: UIImage? {
        return R.image.ethereum_logo_256()
    }

    private var symbol: String {
        return token.symbol
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .medium)
    }

    var amount: String {
        return String(
            format: "%@ %@",
            shortFormatter.string(from: BigInt(token.value) ?? BigInt(), decimals: token.decimals),
            symbol
        )
    }

    init(
        token: TokenObject,
        config: Config = Config(),
        store: TokensDataStore,
        tokensNetwork: TokensNetworkProtocol
    ) {
        self.token = token
        self.config = config
        self.store = store
        self.tokensNetwork = tokensNetwork
    }

    mutating func fetch() {
        getTokenBalance()
    }

    private func getTokenBalance() {
        tokensNetwork.tokenBalance(for: token) { (result) in
            guard let balance = result.1 else {
                return
            }
            self.store.update(token: self.token, action: .updateValue(balance.value))
        }
    }

    mutating func tokenObservation(with completion: @escaping (() -> Void)) {
        notificationToken = token.observe { change in
            switch change {
            case .change, .deleted, .error:
                completion()
            }
        }
    }
}
