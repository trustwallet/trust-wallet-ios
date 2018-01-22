// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import WebKit
import JavaScriptCore

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

struct DappCallback {
    let id: Int
    let value: DappCallbackValue
}

struct DappCommand: Decodable {
    let name: Method
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
        var callback_
        function addCallback(callbacksCount, cb) {
            callbacks[callbacksCount] = cb
            callbacksCount++
        }

        function executeCallback(id, value) {
            console.log("executeCallback")
            let callback = callbacks[id](null, value)
            console.log("id", id)
            console.log("value", value)
            //invalid argument 0: json: cannot unmarshal non-string into Go value of type hexutil.Byte
        }

        const engine = ZeroClientProvider({
            getAccounts: function(cb) {
                return cb(null, ["\(session.account.address.description)"])
            },
            rpcUrl: "\(session.config.rpcURL.absoluteString)",
            sendTransaction: function(tx, cb) {
                console.log("here." + tx)
                webkit.messageHandlers.postMessage({"name": "sendTransaction", "object": tx})
            },
            signTransaction: function(tx, cb) {
                console.log("here2.", tx)
                addCallback(callbacksCount, cb)
                webkit.messageHandlers.signTransaction.postMessage({"name": "signTransaction", "object": tx})
                callback_ = cb
            },
            signMessage: function(cb) {
                console.log("here.4", cb)
                webkit.messageHandlers.signMessage.postMessage({"name": "signMessage", "object": message})
            },
            signPersonalMessage: function(message, cb) {
                console.log("here.5", cb)
                webkit.messageHandlers.signPersonalMessage.postMessage({"name": "signPersonalMessage", "object": message})
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
        webView.load(URLRequest(url: URL(string: "https://tokenfactory.netlify.com/#/factory")!))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func notifyFinish(callback: DappCallback) {
        let evString = "callback_(null, \"\(callback.value.object)\")"
        NSLog("evString \(evString)")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.webView.evaluateJavaScript(evString, completionHandler: nil)
        }
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

    }
}

extension BrowserViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        let method = Method(string: message.name)

        switch method {
        case .sendTransaction, .signTransaction:
            guard let body = message.body as? [String: AnyObject],
                let jsonString = body.jsonString else { return }

            let command = try! decoder.decode(DappCommand.self, from: jsonString.data(using: .utf8)!)
            let action = DappAction.fromCommand(command)

            delegate?.didCall(action: action, callbackID: 0)
            return
        case .signPersonalMessage: break
            //delegate?.didCall(action: .signMessage("hello"))
        default: break
        }

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
            //delegate?.didCall(action: action)
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
