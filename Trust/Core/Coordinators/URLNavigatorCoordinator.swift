// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import URLNavigator
import TrustWalletSDK

struct URLNavigatorCoordinator {
    let branch = BranchCoordinator()
    let navigator = Navigator()

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        var handled = branch.application(app, open: url, options: options)

        if !handled {
            handled = navigator.open(url)
        }
        return handled
    }
}
