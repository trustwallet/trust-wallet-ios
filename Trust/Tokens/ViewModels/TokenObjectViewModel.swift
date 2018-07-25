// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

struct TokenObjectViewModel {

    let token: TokenObject

    var imageURL: URL? {
        return URL(string: imagePath)
    }

    var title: String {
        return token.name.isEmpty ? token.symbol : (token.name + " (" + token.symbol + ")")
    }

    var placeholder: UIImage? {
        switch token.type {
        case .coin: return R.image.ethereum_logo_256()
        case .ERC20: return R.image.erc20()
        }
    }

    private var imagePath: String {
        let formatter = ImageURLFormatter()
        switch token.type {
        case .coin:
            return formatter.image(for: token.coin)
        case .ERC20:
            return formatter.image(for: token.contract)
        }
    }
}
