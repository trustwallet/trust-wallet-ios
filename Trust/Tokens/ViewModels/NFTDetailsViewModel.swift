// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class NFTDetailsViewModel {

    let token: CollectibleTokenObject
    let server: RPCServer

    init(token: CollectibleTokenObject, server: RPCServer) {
        self.token = token
        self.server = server
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
        return R.string.localizable.send()
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
        return server.opensea(with: token.contract, and: token.id)
    }
}
