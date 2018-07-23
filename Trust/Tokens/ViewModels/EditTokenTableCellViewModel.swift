// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

struct EditTokenTableCellViewModel {

    let token: TokenObject
    let coinTicker: CoinTicker?
    let isLocal: Bool

    init(
        token: TokenObject,
        coinTicker: CoinTicker?,
        isLocal: Bool = true
    ) {
        self.token = token
        self.coinTicker = coinTicker
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
        return token.placeholder
    }

    var imageUrl: URL? {
        return token.imageURL
    }

    var isEnabled: Bool {
        return !token.isDisabled
    }

    var contractText: String? {
        switch token.type {
        case .coin:
            return .none
        case .ERC20:
            return token.contract + " (ERC20) "
        }
    }

    var isTokenContractLabelHidden: Bool {
        if contractText == nil {
            return true
        }
        return false
    }

    var isSwitchHidden: Bool {
        return !isLocal
    }
}
