// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

struct EditTokenTableCellViewModel {

    let token: TokenObject
    let coinTicker: CoinTicker?
    let config: Config
    let isLocal: Bool

    init(
        token: TokenObject,
        coinTicker: CoinTicker?,
        config: Config,
        isLocal: Bool = true
    ) {
        self.token = token
        self.coinTicker = coinTicker
        self.config = config
        self.isLocal = isLocal
    }

    var title: String {
        return token.title
    }

    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .medium)
    }

    var titleTextColor: UIColor {
        return Colors.black
    }

    var placeholderImage: UIImage? {
        return R.image.ethereum_logo_256()
    }

    var imageUrl: URL? {
        return token.imageURL
    }

    var isEnabled: Bool {
        return !token.isDisabled
    }

    private var isAvailableForChange: Bool {
        // One version had an option to disable ETH token. Adding functionality to enable it back.
        if token.contract == TokensDataStore.etherToken(for: config).contract && token.isDisabled == true {
            return false
        }
        return token.contract == TokensDataStore.etherToken(for: config).contract ? true : false
    }

    var contractText: String? {
        if !isAvailableForChange {
            return token.contract
        }
        return .none
    }

    var isTokenContractLabelHidden: Bool {
        if contractText == nil {
            return true
        }
        return false
    }

    var isSwitchHidden: Bool {
        return isAvailableForChange || !isLocal
    }
}
