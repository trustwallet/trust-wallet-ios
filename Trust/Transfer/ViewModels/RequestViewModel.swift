// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import UIKit

struct RequestViewModel {

    let server: RPCServer
    let token: TokenObject

    init(
        server: RPCServer,
        token: TokenObject
    ) {
        self.server = server
        self.token = token
    }

    var title: String {
        return token.displayName
    }

    var myAddressText: String {
        return token.address.description
    }

    var shareMyAddressText: String {
        return String(
            format: NSLocalizedString("request.myAddressIs.label.title", value: "My %@ address is: %@", comment: ""),
            server.name, myAddressText
        )
    }

    var headlineText: String {
        return String(
            format: NSLocalizedString("request.myPublicaddress.label.title", value: "My Public %@ wallet address", comment: ""),
            server.name
        )
    }

    var copyWalletText: String {
        return NSLocalizedString("request.copyWallet.button.title", value: "Copy wallet address", comment: "")
    }

    var addressCopiedText: String {
        return NSLocalizedString("request.addressCopied.title", value: "Address copied", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }
}
