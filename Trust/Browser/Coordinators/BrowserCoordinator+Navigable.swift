// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import URLNavigator

extension BrowserCoordinator: URLNavigable {
    func register(with navigator: Navigator) {
        navigator.handle("trust://browse") { url, _, _ in
            guard let target = url.queryParameters["target"],
                let targetUrl = URL(string: target) else {
                return false
            }
            self.rootViewController.goTo(url: targetUrl)
            return true
        }
    }
}
