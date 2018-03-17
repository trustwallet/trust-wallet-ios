// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TokenViewModel {

    let type: TokenType
    let config: Config

    init(
        type: TokenType,
        config: Config = Config()
    ) {
        self.type = type
        self.config = config
    }

    var title: String {
        switch type {
        case .ether:
            return config.server.displayName
        case .token(let token):
            return token.displayName
        }
    }

    var imageURL: URL? {
        switch type {
        case .ether:
            return .none
        case .token(let token):
            return token.imageURL
        }
    }

    var imagePlaceholder: UIImage? {
        return R.image.ethereum_logo_256()
    }

    private var symbol: String {
        switch type {
        case .ether: return config.server.symbol
        case .token(let token): return token.symbol
        }
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: .medium)
    }

    var amountText: String {
        return String(format: "1.12 %@", symbol) //TODO: Implement
    }
}
