// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore
import UIKit

struct RequestViewModel {

    let coinTypeViewModel: CoinTypeViewModel

    init(
        coinTypeViewModel: CoinTypeViewModel
    ) {
        self.coinTypeViewModel = coinTypeViewModel
    }

    var title: String {
        return coinTypeViewModel.name
    }

    var myAddressText: String {
        return coinTypeViewModel.address.description
    }

    var shareMyAddressText: String {
        return String(
            format: NSLocalizedString("request.myAddressIs.label.title", value: "My %@ address is: %@", comment: ""),
            coinTypeViewModel.name, myAddressText
        )
    }

    var headlineText: String {
        return String(
            format: NSLocalizedString("request.myPublicaddress.label.title", value: "My Public %@ wallet address", comment: ""),
            coinTypeViewModel.name
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
