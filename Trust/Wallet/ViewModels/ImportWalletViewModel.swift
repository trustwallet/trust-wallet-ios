// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ImportWalletViewModel {

    private let config: Config

    init(
        config: Config = Config()
    ) {
        self.config = config
    }

    var title: String {
        return NSLocalizedString("import.navigation.title", value: "Import Wallet", comment: "")
    }

    var watchAddressPlaceholder: String {
        return String(format: NSLocalizedString("import.wallet.watch.placeholder", value: "%@ Address", comment: ""), config.server.name)
    }
}
