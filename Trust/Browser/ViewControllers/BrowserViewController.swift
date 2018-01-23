// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import WebKit
import JavaScriptCore
import Result

struct DappCommandObjectValue: Decodable {
    public var value: String = ""
    public init(from coder: Decoder) throws {
        let container = try coder.singleValueContainer()
        if let intValue = try? container.decode(Int.self) {
            self.value = String(intValue)
        } else {
            self.value = try container.decode(String.self)
        }
    }
}

enum DappCallbackValue {
    case signTransaction(Data)

    var object: String {
        switch self {
        case .signTransaction(let value):
            return value.hexEncoded
        }
    }
}

enum DAppError: Error {
    case cancelled
}

struct DappCallback {
    let id: Int
    let value: DappCallbackValue
}

struct DappCommand: Decodable {
    let name: Method
    let id: Int
    let object: [String: DappCommandObjectValue]
}

enum Method: String, Decodable {
    //case getAccounts
    case sendTransaction
    case signTransaction
    case signPersonalMessage
    case signMessage
    case unknown

    init(string: String) {
        self = Method(rawValue: string) ?? .unknown
    }
}

protocol BrowserViewControllerDelegate: class {
    func didCall(action: DappAction, callbackID: Int)
}
class BrowserViewController: UIViewController {

    let session: WalletSession

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
        let callbacksCount = 0;
        let callbacks = {};
        function addCallback(cb) {
            callbacksCount++
            callbacks[callbacksCount] = cb
            return callbacksCount
        }

        function executeCallback(id, error, value) {
            console.log("executeCallback")
            console.log("id", id)
            console.log("value", value)
            console.log("error", error)
            let callback = callbacks[id](error, value)
        }

        const engine = ZeroClientProvider({
            getAccounts: function(cb) {
                return cb(null, ["\(session.account.address.description)"])
            },
            rpcUrl: "\(session.config.rpcURL.absoluteString)",
            sendTransaction: function(tx, cb) {
                console.log("here." + tx)
                let id = addCallback(cb)
                webkit.messageHandlers.postMessage({"name": "sendTransaction", "object": tx, id: id})
            },
            signTransaction: function(tx, cb) {
                console.log("here2.", tx)
                let id = addCallback(cb)
                webkit.messageHandlers.signTransaction.postMessage({"name": "signTransaction", "object": tx, id: id})
            },
            signMessage: function(cb) {
                console.log("here.4", cb)
                let id = addCallback(cb)
                webkit.messageHandlers.signMessage.postMessage({"name": "signMessage", "object": message, id: id})
            },
            signPersonalMessage: function(message, cb) {
                console.log("here.5", cb)
                let id = addCallback(cb)
                webkit.messageHandlers.signPersonalMessage.postMessage({"name": "signPersonalMessage", "object": message, id: id})
            },
        })
        engine.start()
        var web3 = new Web3(engine)
        window.web3 = web3
        web3.eth.accounts = ["\(session.account.address.description)"]
        web3.eth.getAccounts = function(cb) {
            return cb(null, ["\(session.account.address.description)"])
        }
        web3.eth.defaultAccount = "\(session.account.address.description)"

        """

        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.add(self, name: Method.sendTransaction.rawValue)
        config.userContentController.add(self, name: Method.signTransaction.rawValue)
        config.userContentController.add(self, name: Method.signPersonalMessage.rawValue)
        config.userContentController.add(self, name: Method.signMessage.rawValue)

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

//        if let url = Bundle.main.url(forResource: "demo", withExtension: "html") {
//            webView.load(URLRequest(url: url))
//        }
        webView.load(URLRequest(url: URL(string: "https://ropsten.kyber.network/")!))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func notifyFinish(callbackID: Int, value: Result<DappCallback, DAppError>) {
        let script: String = {
            switch value {
            case .success(let result):
                return "executeCallback(\(callbackID), null, \"\(result.value.object)\")"
            case .failure(let error):
                return "executeCallback(\(callbackID), \"\(error)\", null)"
            }
        }()
        NSLog("script \(script)")
        self.webView.evaluateJavaScript(script, completionHandler: nil)
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }
}

extension BrowserViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        let method = Method(string: message.name)
        guard let body = message.body as? [String: AnyObject],
            let jsonString = body.jsonString,
            let command = try? decoder.decode(DappCommand.self, from: jsonString.data(using: .utf8)!) else {
                return
        }
        let action = DappAction.fromCommand(command)

        switch method {
        case .sendTransaction, .signTransaction:
            delegate?.didCall(action: action, callbackID: command.id)
        case .signPersonalMessage:
            delegate?.didCall(action: action, callbackID: command.id)
        case .signMessage, .unknown:
            break
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
