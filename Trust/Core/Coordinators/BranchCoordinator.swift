// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Branch

final class BranchCoordinator {

    private struct Keys {
        static let isFirstSession = "is_first_session"
        static let clickedBranchLink = "clicked_branch_link"
    }

    private var events = [BranchEvent]()
    var newEventClosure: ((BranchEvent) -> (Bool))?
    var lastEvent: BranchEvent? {
        return events.last
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

            guard let event = BranchEventParser.from(params: params) else { return }
            self.handleEvent(event)
        })
    }

    func handleEvent(_ event: BranchEvent) {
        guard let newEventClosure = newEventClosure else {
            return events.append(event)
        }
        if !newEventClosure(event) {
            events.append(event)
        }
    }

    func clearEvents() {
        events.removeAll()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return Branch.getInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey: Any] = [:]) -> Bool {
        return Branch.getInstance().application(app, open: url, options: options)
    }
}
