// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import URLNavigator
import TrustSDK

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
        let trustSDK = TrustSDK(callbackScheme: "trust")

        

//        navigator.handle("trust://sign-transaction") { url, _, _ in
//            if let command = parse(url: url as! URL) {
//                self.handleCommand(command)
//            }
//            return true
//        }

        navigator.handle("trust://sign-message") { url, _, _ in
            let url: URL = url as! URL
            //if trustSDK.handleCallback(url: url as! URL) {
                self.handleTrustURL(url)
            //}
            return true
        }
    }
}

extension String {
    var data:          Data  { return Data(utf8) }
    var base64Encoded: Data  { return data.base64EncodedData() }
    var base64Decoded: Data? { return Data(base64Encoded: self) }
}

extension Data {
    var string: String? { return String(data: self, encoding: .utf8) }
}
