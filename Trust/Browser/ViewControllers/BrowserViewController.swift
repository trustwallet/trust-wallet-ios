// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import WebKit
import JavaScriptCore
import Result

protocol BrowserViewControllerDelegate: class {
    func didCall(action: DappAction, callbackID: Int)
}

class BrowserViewController: UIViewController {

    private var myContext = 0
    let account: Wallet
    let sessionConfig: Config

    private struct Keys {
        static let estimatedProgress = "estimatedProgress"
        static let developerExtrasEnabled = "developerExtrasEnabled"
        static let URL = "URL"
    }

    lazy var webView: WKWebView = {
        let webView = WKWebView(
            frame: .zero,
            configuration: self.config
        )
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.uiDelegate = self
        if isDebug {
            webView.configuration.preferences.setValue(true, forKey: Keys.developerExtrasEnabled)
        }
        return webView
    }()
    weak var delegate: BrowserViewControllerDelegate?
    let decoder = JSONDecoder()
    private let urlParser = BrowserURLParser()

    var browserNavBar: BrowserNavigationBar? {
        return navigationController?.navigationBar as? BrowserNavigationBar
    }
    let progressView = UIProgressView(progressViewStyle: .default)

    lazy var config: WKWebViewConfiguration = {
        return WKWebViewConfiguration.make(for: account, with: sessionConfig, in: self)
    }()

    init(
        account: Wallet,
        config: Config
    ) {
        self.account = account
        self.sessionConfig = config

        super.init(nibName: nil, bundle: nil)

        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)

        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = Colors.darkBlue
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
        webView.addObserver(self, forKeyPath: Keys.URL, options: [.new, .initial], context: &myContext)
        goHome()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        browserNavBar?.browserDelegate = self
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
        guard let url = URL(string: Constants.dappsBrowserURL) else { return }
        webView.load(URLRequest(url: url))
        browserNavBar?.textField.text = url.absoluteString
    }

    private func reload() {
        webView.reload()
    }

    private func stopLoading() {
        webView.stopLoading()
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
        } else if keyPath == Keys.URL {
            if let url = webView.url {
                self.browserNavBar?.textField.text = url.absoluteString
            }
        }
    }

    deinit {
        webView.removeObserver(self, forKeyPath: Keys.estimatedProgress)
        webView.removeObserver(self, forKeyPath: Keys.URL)
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
        let shareAction = UIAlertAction(title: NSLocalizedString("browser.share.button.title", value: "Share", comment: ""), style: .default) { [unowned self] _ in
            self.share()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", value: "Cancel", comment: ""), style: .cancel) { _ in }

        alertController.addAction(homeAction)
        alertController.addAction(reloadAction)
        alertController.addAction(shareAction)
        alertController.addAction(cancelAction)
        return alertController
    }

    private func makeShareController(url: URL) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }

    private func share() {
        guard let url = webView.url else { return }
        guard let navigationController = navigationController else { return }
        let controller = makeShareController(url: url)
        controller.popoverPresentationController?.sourceView = navigationController.view
        controller.popoverPresentationController?.sourceRect = navigationController.view.centerRect
        navigationController.present(controller, animated: true, completion: nil)
    }

    func handleError(error: Error) {
        if error.code == NSURLErrorCancelled {
            return
        } else {
            displayError(error: error)
        }
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
            guard let url = urlParser.url(from: string) else { return }
            goTo(url: url)
        case .beginEditing:
            stopLoading()
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
        reloadButtons()
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error: error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        handleError(error: error)
    }
}

extension BrowserViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

extension BrowserViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {

        guard let body = message.body as? [String: AnyObject],
            let jsonString = body.jsonString,
            let command = try? decoder.decode(DappCommand.self, from: jsonString.data(using: .utf8)!) else {
                return
        }
        let action = DappAction.fromCommand(command)

        delegate?.didCall(action: action, callbackID: command.id)
    }
}
