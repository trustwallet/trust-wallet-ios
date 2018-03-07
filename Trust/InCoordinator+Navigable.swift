// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import URLNavigator

extension InCoordinator: URLNavigable {
    func register(with navigator: Navigator) {
        navigator.handle(URLSchemes.browser) { url, _, _ in
            guard let target = url.queryParameters["target"],
                let targetUrl = URL(string: target) else {
                    return false
            }
            self.showTab(.browser(openURL: targetUrl))
            return true
        }
    }
}
