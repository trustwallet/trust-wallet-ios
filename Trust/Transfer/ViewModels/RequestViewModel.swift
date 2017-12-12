// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct RequestViewModel {

    let account: Account
    let config: Config

    init(
        account: Account,
        config: Config
    ) {
        self.account = account
        self.config = config
    }

    var myAddressText: String {
        return account.address.address
    }

    var shareMyAddressText: String {
        return String(
            format: NSLocalizedString("request.myAddressIs.label.title", value: "My %@ address is: %@", comment: ""),
            config.server.name, myAddressText
        )
    }

    var headlineText: String {
        return String(
            format: NSLocalizedString("request.myPublicaddress.label.title", value: "My Public %@ wallet address", comment: ""),
            config.server.name
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
