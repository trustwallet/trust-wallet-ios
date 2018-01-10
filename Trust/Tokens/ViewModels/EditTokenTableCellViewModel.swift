// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct EditTokenTableCellViewModel {

    let token: TokenObject
    let coinTicker: CoinTicker?

    init(
        token: TokenObject,
        coinTicker: CoinTicker?
    ) {
        self.token = token
        self.coinTicker = coinTicker
    }

    var title: String {
        return token.name.isEmpty ? token.symbol : token.name
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

    var contractText: String {
        return token.contract
    }
}
