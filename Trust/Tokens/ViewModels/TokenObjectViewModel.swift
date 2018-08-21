// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustCore

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
        case .coin:
            return R.image.ethereum_logo_256()
        case .ERC20:
            let imageCache = ImageCaching.shared
            let key = token.coin.tokenTitle
            guard let image = imageCache.getImage(for: key) else {
                return imageCache.setImage(
                    TokenImageGenerator.drawImagesAndText(title: token.coin.tokenTitle),
                    for: key
                )
            }
            return image
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
