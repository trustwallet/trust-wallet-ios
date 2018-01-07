// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import WebKit
import JavaScriptCore

struct DappCommand: Decodable {
    let name: Method
    let object: [String: String]
}

enum Method: String, Decodable {
    //case getAccounts
    case signTransaction
    case sign
    //case signMessage
}

protocol BrowserViewControllerDelegate: class {
    func didCall(action: DappAction)
}
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

    weak var delegate: BrowserViewControllerDelegate?
    let decoder = JSONDecoder()

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
        function runCommand(command, object) {
            webkit.messageHandlers.command.postMessage({"name": command, "object": object})
        }

        let web3 = new Web3(new Web3.providers.HttpProvider("\(session.config.rpcURL.absoluteString)"));
        web3.eth.defaultAccount = "\(session.account.address.address)"
        web3.eth.signTransaction = function(tx, callback) {
            runCommand("signTransaction", tx)
        }
        web3.eth.sign = function(message, callback){
            runCommand("sign", {"message": message})
        }
        """

        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.add(self, name: "command")

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

        if let url = Bundle.main.url(forResource: "demo", withExtension: "html") {
            webView.load(URLRequest(url: url))
        }
        //webView.load(URLRequest(url: URL(string: "https://poanetwork.github.io/poa-dapps-validators/")!))
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

        guard
            let body = message.body as? [String: AnyObject],
            let jsonString = body.jsonString
        else { return }

        do {
            let command = try decoder.decode(
                DappCommand.self,
                from: jsonString.data(using: .utf8)!
            )
            let action = DappAction.fromCommand(command)
            delegate?.didCall(action: action)
        } catch {
            NSLog("error \(error)")
        }
    }
}

struct SendTransaction: Decodable {
    let from: String
    let to: String?
    let value: String?
    let gas: String?
    let gasPrice: String?
    let data: String?
    let nonce: String?
}
