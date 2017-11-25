// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct ExchangeTokenViewModel {

    let token: ExchangeToken

    init(token: ExchangeToken) {
        self.token = token
    }

    var nameText: String {
        return token.name
    }

    var balanceText: String {
        return "\(token.balance)"
    }

    var image: UIImage? {
        return token.image
    }

    var isEnabled: Bool {
        return token.balance == 0
    }

    var alpha: CGFloat {
        return isEnabled ? 1 : 0.5
    }
}
