// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import URLNavigator

struct URLNavigatorCoordinator {
    let branch = BranchCoordinator()
    let navigator = Navigator()

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        var handled = branch.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        if !handled {
            handled = navigator.open(url)
        }
        return handled
    }
}
