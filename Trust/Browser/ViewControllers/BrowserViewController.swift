// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import WebKit

class BrowserViewController: UIViewController {

    let session: WalletSession

    enum Method: String {
        case getAccounts
        case signTransaction
        case signMessage
        case signPersonalMessage
        case publishTransaction
        case approveTransaction
    }

    lazy var webView: WKWebView = {
        let webView = WKWebView(
            frame: .zero,
            configuration: self.config
        )
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.isScrollEnabled = true
        webView.navigationDelegate = self
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
        return webView
    }()

    lazy var config: WKWebViewConfiguration = {
        let config = WKWebViewConfiguration()

        var js = ""

        if let filepath = Bundle.main.path(forResource: "web3.min", ofType: "js") {
            do {
                js += try String(contentsOfFile: filepath)
                NSLog("Loaded web3.js")
            } catch {
                NSLog("Failed to load web.js")
            }
        } else {
            NSLog("web3.js not found in bundle")
        }

        js +=
        """
        let web3 = new Web3(new Web3.providers.HttpProvider("\(session.config.rpcURL.absoluteString)"));
        web3.eth.defaultAccount = "\(session.account.address.address)"
        window.web3 = web3
        """

        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)

        config.userContentController.add(self, name: Method.getAccounts.rawValue)
        config.userContentController.add(self, name: Method.signPersonalMessage.rawValue)
        config.userContentController.add(self, name: Method.signMessage.rawValue)
        config.userContentController.add(self, name: Method.signTransaction.rawValue)
        config.userContentController.add(self, name: Method.publishTransaction.rawValue)
        config.userContentController.add(self, name: Method.approveTransaction.rawValue)

        config.userContentController.addUserScript(userScript)
        return config
    }()

    init(
        session: WalletSession
    ) {
        self.session = session

        super.init(nibName: nil, bundle: nil)

        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        webView.load(URLRequest(url: URL(string: "https://poanetwork.github.io/poa-dapps-validators/")!))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }
}

extension BrowserViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        NSLog("message \(message.body)")
    }
}
