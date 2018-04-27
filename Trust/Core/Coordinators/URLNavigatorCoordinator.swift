// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import URLNavigator

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
