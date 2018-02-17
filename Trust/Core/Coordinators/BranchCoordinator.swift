// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Branch

class BranchCoordinator {

    private struct Keys {
        static let isFirstSession = "is_first_session"
        static let clickedBranchLink = "clicked_branch_link"
    }

    func didFinishLaunchingWithOptions(launchOptions: [UIApplicationLaunchOptionsKey: Any]?) {
        Branch.getInstance().initSession(launchOptions: launchOptions, andRegisterDeepLinkHandler: { params, error in
            guard
                error == nil,
                let params = params as? [String: AnyObject] else {
                    return
            }
            if
                let _ = params[Keys.isFirstSession] as? Bool,
                let _ = params[Keys.clickedBranchLink] as? Bool {
                Branch.getInstance().getLatestReferringParams()
            }
        })
    }
}
