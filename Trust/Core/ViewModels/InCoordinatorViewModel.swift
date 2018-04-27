// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct InCoordinatorViewModel {

    let config: Config
    let preferences: PreferencesController

    init(
        config: Config,
        preferences: PreferencesController = PreferencesController()
    ) {
        self.config = config
        self.preferences = preferences
    }

    var browserBarItem: UITabBarItem {
        return UITabBarItem(
            title: NSLocalizedString("browser.tabbar.item.title", value: "Browser", comment: ""),
            image: R.image.dapps_icon(),
            selectedImage: nil
        )
    }

    var transactionsBarItem: UITabBarItem {
        return UITabBarItem(
            title: NSLocalizedString("transactions.tabbar.item.title", value: "Transactions", comment: ""),
            image: R.image.feed(),
            selectedImage: nil
        )
    }

    var walletBarItem: UITabBarItem {
        return UITabBarItem(
            title: NSLocalizedString("wallet.navigation.title", value: "Wallet", comment: ""),
            image: R.image.settingsWallet(),
            selectedImage: nil
        )
    }

    var settingsBarItem: UITabBarItem {
        return UITabBarItem(
            title: NSLocalizedString("settings.navigation.title", value: "Settings", comment: ""),
            image: R.image.settings_icon(),
            selectedImage: nil
        )
    }
}
