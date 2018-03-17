// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import BigInt

struct TokenViewModel {

    private let shortFormatter = EtherNumberFormatter.short

    let token: TokenObject
    let config: Config

    init(
        token: TokenObject,
        config: Config = Config()
    ) {
        self.token = token
        self.config = config
    }

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
        return shortFormatter.string(from: BigInt(token.value) ?? BigInt(), decimals: token.decimals)
    }
}
