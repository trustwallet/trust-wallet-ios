// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct EditTokenTableCellViewModel {

    let token: TokenObject
    let coinTicker: CoinTicker?
    let config: Config

    init(
        token: TokenObject,
        coinTicker: CoinTicker?,
        config: Config
    ) {
        self.token = token
        self.coinTicker = coinTicker
        self.config = config
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
        return R.image.ethereumToken()
    }

    var imageUrl: URL? {
        return coinTicker?.imageURL
    }

    var isEnabled: Bool {
        return !token.isDisabled
    }

    private var isAvailableForChange: Bool {
        return token.contract == TokensDataStore.etherToken(for: config).contract ? true : false
    }

    var contractText: String? {
        if !isAvailableForChange {
            return token.contract
        }
        return .none
    }

    var isSwitchHidden: Bool {
        return isAvailableForChange
    }
}
