// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class NFTDetailsViewModel {

    let token: NonFungibleTokenObject

    init(token: NonFungibleTokenObject) {
        self.token = token
    }

    var title: String {
        return token.name
    }

    var descriptionText: String {
        return token.annotation
    }

    var descriptionTextColor: UIColor {
        return Colors.lightBlack
    }

    var imageURL: URL? {
        return token.imageURL
    }

    var placeholder: UIImage? {
        return R.image.launch_screen_logo()
    }

    var sendButtonTitle: String {
        return NSLocalizedString("Send", value: "Send", comment: "")
    }

    var internalButtonTitle: String {
        return String(format: NSLocalizedString("nft.details.internal.button.title", value: "Open on %@", comment: ""), token.category)
    }

    var externalButtonTitle: String {
        return NSLocalizedString("nft.details.external.button.title", value: "Open on OpenSea.io", comment: "")
    }

    var internalURL: URL? {
        return token.extentalURL
    }

    var externalURL: URL? {
        return Config().opensea(with: token.contract, and: token.id)
    }
}
