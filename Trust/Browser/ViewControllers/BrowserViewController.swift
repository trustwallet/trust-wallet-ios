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
    case signMessage(Data)

    var object: String {
        switch self {
        case .signTransaction(let data):
            return data.hexEncoded
        case .signMessage(let data):
            return data.hexEncoded
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

    private var myContext = 0
    let session: WalletSession

    private struct Keys {
        static let estimatedProgress = "estimatedProgress"
        static let developerExtrasEnabled = "developerExtrasEnabled"
    }

    lazy var webView: WKWebView = {
        let webView = WKWebView(
            frame: .zero,
            configuration: self.config
        )
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        if isDebug {
            webView.configuration.preferences.setValue(true, forKey: Keys.developerExtrasEnabled)
        }
        return webView
    }()
    weak var delegate: BrowserViewControllerDelegate?
    let decoder = JSONDecoder()

    var browserNavBar: BrowserNavigationBar? {
        return navigationController?.navigationBar as? BrowserNavigationBar
    }
    let progressView = UIProgressView(progressViewStyle: .default)

    lazy var config: WKWebViewConfiguration = {
        return WKWebViewConfiguration.make(for: session, in: self)
    }()

    init(
        session: WalletSession
    ) {
        self.session = session

        super.init(nibName: nil, bundle: nil)

        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = Colors.blue
        webView.addSubview(progressView)
        webView.bringSubview(toFront: progressView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),

            progressView.topAnchor.constraint(equalTo: view.layoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3),
        ])
        view.backgroundColor = .white
        webView.addObserver(self, forKeyPath: Keys.estimatedProgress, options: .new, context: &myContext)
        goHome()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        browserNavBar?.browserDelegate = self
        refreshURL()
        reloadButtons()
    }

    func goTo(url: URL) {
        webView.load(URLRequest(url: url))
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

    private func goHome() {
        webView.load(URLRequest(url: URL(string: Constants.dappsBrowserURL)!))
    }

    private func reload() {
        webView.reload()
    }

    private func refreshURL() {
        browserNavBar?.textField.text = webView.url?.absoluteString
    }

    private func reloadButtons() {
        browserNavBar?.goBack.isEnabled = webView.canGoBack
        browserNavBar?.goForward.isEnabled = webView.canGoForward
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change else { return }
        if context != &myContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == Keys.estimatedProgress {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                progressView.progress = progress
                progressView.isHidden = progress == 1
            }
        }
    }

    deinit {
        webView.removeObserver(self, forKeyPath: Keys.estimatedProgress)
    }

    private func presentMoreOptions(sender: UIView) {
        let alertController = makeMoreAlertSheet(sender: sender)
        present(alertController, animated: true, completion: nil)
    }

    private func makeMoreAlertSheet(sender: UIView) -> UIAlertController {
        let alertController = UIAlertController(
            title: nil,
            message: nil,
            preferredStyle: .actionSheet
        )
        alertController.popoverPresentationController?.sourceView = sender
        alertController.popoverPresentationController?.sourceRect = sender.centerRect
        let homeAction = UIAlertAction(title: NSLocalizedString("browser.home.button.title", value: "Home", comment: ""), style: .default) { [unowned self] _ in
            self.goHome()
        }
        let reloadAction = UIAlertAction(title: NSLocalizedString("browser.reload.button.title", value: "Reload", comment: ""), style: .default) { [unowned self] _ in
            self.reload()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", value: "Cancel", comment: ""), style: .cancel) { _ in }

        alertController.addAction(homeAction)
        alertController.addAction(reloadAction)
        alertController.addAction(cancelAction)
        return alertController
    }
}

extension BrowserViewController: BrowserNavigationBarDelegate {
    func did(action: BrowserAction) {
        switch action {
        case .goForward:
            webView.goForward()
        case .goBack:
            webView.goBack()
        case .more(let sender):
            presentMoreOptions(sender: sender)
        case .enter(let string):
            guard let url = URL(string: string) else { return }
            goTo(url: url)
        }
        reloadButtons()
    }
}

extension BrowserViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        refreshURL()
        reloadButtons()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        refreshURL()
        reloadButtons()
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
