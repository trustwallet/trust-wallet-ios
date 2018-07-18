// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import URLNavigator
import TrustWalletSDK

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

        navigator.handle("trust://sign-transaction") { url, _, _ in
            return self.localSchemeCoordinator?.trustWalletSDK.handleOpen(url: url as! URL) ?? false
        }

        navigator.handle("trust://sign-message") { url, _, _ in
            return self.localSchemeCoordinator?.trustWalletSDK.handleOpen(url: url as! URL) ?? false
        }

        navigator.handle("trust://sign-personal-message") { url, _, _ in
            return self.localSchemeCoordinator?.trustWalletSDK.handleOpen(url: url as! URL) ?? false
        }
    }
}
