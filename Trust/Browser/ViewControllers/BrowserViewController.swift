// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import WebKit
import JavaScriptCore
import Result

protocol BrowserViewControllerDelegate: class {
    func didCall(action: DappAction, callbackID: Int)
    func didAddBookmark(bookmark: Bookmark)
    func didOpenBookmarkList()
    func didOpenQRCode()
    func didVisitURL(url: URL, title: String)
}

class BrowserViewController: UIViewController {

    private var myContext = 0
    let account: Wallet
    let sessionConfig: Config

    private struct Keys {
        static let estimatedProgress = "estimatedProgress"
        static let developerExtrasEnabled = "developerExtrasEnabled"
        static let URL = "URL"
        static let ClientName = "Trust"
    }

    private lazy var userClient: String = {
        return Keys.ClientName + "/" + (Bundle.main.versionNumber ?? "")
    }()

    lazy var webView: WKWebView = {
        let webView = WKWebView(
            frame: .zero,
            configuration: self.config
        )
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        if isDebug {
            webView.configuration.preferences.setValue(true, forKey: Keys.developerExtrasEnabled)
        }
        return webView
    }()

    lazy var errorView: BrowserErrorView = {
        let errorView = BrowserErrorView()
        errorView.translatesAutoresizingMaskIntoConstraints = false
        errorView.delegate = self
        return errorView
    }()

    weak var delegate: BrowserViewControllerDelegate?
    private let urlParser = BrowserURLParser()

    var browserNavBar: BrowserNavigationBar? {
        return navigationController?.navigationBar as? BrowserNavigationBar
    }

    lazy var progressView: UIProgressView = {
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.tintColor = Colors.darkBlue
        progressView.trackTintColor = .clear
        return progressView
    }()

    //Take a look at this issue : https://stackoverflow.com/questions/26383031/wkwebview-causes-my-view-controller-to-leak
    lazy var config: WKWebViewConfiguration = {
        return WKWebViewConfiguration.make(for: account, with: sessionConfig, in: ScriptMessageProxy(delegate: self))
    }()

    init(
        account: Wallet,
        config: Config
    ) {
        self.account = account
        self.sessionConfig = config

        super.init(nibName: nil, bundle: nil)

        view.addSubview(webView)
        injectUserAgent()

        webView.addSubview(progressView)
        webView.bringSubview(toFront: progressView)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),

            progressView.topAnchor.constraint(equalTo: view.layoutGuide.topAnchor),
            progressView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 2),

            errorView.topAnchor.constraint(equalTo: webView.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
        ])
        view.backgroundColor = .white
        webView.addObserver(self, forKeyPath: Keys.estimatedProgress, options: .new, context: &myContext)
        webView.addObserver(self, forKeyPath: Keys.URL, options: [.new, .initial], context: &myContext)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        browserNavBar?.browserDelegate = self
        reloadButtons()
    }

    private func injectUserAgent() {
        webView.evaluateJavaScript("navigator.userAgent") { [weak self] result, _ in
            guard let `self` = self, let currentUserAgent = result as? String else { return }
            self.webView.customUserAgent = currentUserAgent + " " + self.userClient
        }
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

    func goHome() {
        guard let url = URL(string: Constants.dappsBrowserURL) else { return }
        hideErrorView()
        webView.load(URLRequest(url: url))
        browserNavBar?.textField.text = url.absoluteString
    }

    private func qrReader() {
        delegate?.didOpenQRCode()
    }

    private func reload() {
        hideErrorView()
        webView.reload()
    }

    private func stopLoading() {
        webView.stopLoading()
    }

    private func refreshURL() {
        browserNavBar?.textField.text = webView.url?.absoluteString
    }

    private func recordURL() {
        guard let url = webView.url else {
            return
        }
        delegate?.didVisitURL(url: url, title: webView.title ?? "")
    }

    private func reloadButtons() {
        browserNavBar?.goBack.isEnabled = webView.canGoBack
        browserNavBar?.goForward.isEnabled = webView.canGoForward
    }

    private func hideErrorView() {
        errorView.isHidden = true
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
        let QRCodeAction = UIAlertAction(title: NSLocalizedString("browser.qrCode.button.title", value: "QR Reader", comment: ""), style: .default) { [unowned self] _ in
            self.qrReader()
        }
        let reloadAction = UIAlertAction(title: NSLocalizedString("browser.reload.button.title", value: "Reload", comment: ""), style: .default) { [unowned self] _ in
            self.reload()
        }
        let shareAction = UIAlertAction(title: NSLocalizedString("browser.share.button.title", value: "Share", comment: ""), style: .default) { [unowned self] _ in
            self.share()
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", value: "Cancel", comment: ""), style: .cancel) { _ in }
        let addBookmarkAction = UIAlertAction(title: NSLocalizedString("browser.addbookmark.button.title", value: "Add Bookmark", comment: ""), style: .default) { [unowned self] _ in
            self.addBookmark()
        }
        let viewBookmarksAction = UIAlertAction(title: NSLocalizedString("browser.bookmarks.button.title", value: "Bookmarks", comment: ""), style: .default) { [unowned self] _ in
            self.showBookmarks()
        }

        alertController.addAction(reloadAction)
        alertController.addAction(QRCodeAction)
        alertController.addAction(shareAction)
        alertController.addAction(addBookmarkAction)
        alertController.addAction(viewBookmarksAction)
        alertController.addAction(cancelAction)
        return alertController
    }

    private func share() {
        guard let url = webView.url else { return }
        guard let navigationController = navigationController else { return }
        let activityViewController = ActivityViewController.makeShareController(url: url, navigationController: navigationController)
        activityViewController.popoverPresentationController?.sourceView = navigationController.view
        activityViewController.popoverPresentationController?.sourceRect = navigationController.view.centerRect
        navigationController.present(activityViewController, animated: true, completion: nil)
    }

    private func addBookmark() {
        guard let url = webView.url?.absoluteString else { return }
        guard let title = webView.title else { return }
        delegate?.didAddBookmark(bookmark: Bookmark(url: url, title: title))
    }

    private func showBookmarks() {
        delegate?.didOpenBookmarkList()
    }

    func handleError(error: Error) {
        if error.code == NSURLErrorCancelled {
            return
        } else {
            errorView.show(error: error)
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
        case .home:
            goHome()
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
        recordURL()
        reloadButtons()
        hideErrorView()
    }

    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        reloadButtons()
        hideErrorView()
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

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController.alertController(
            title: .none,
            message: message,
            style: .alert,
            in: navigationController!
        )
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", value: "OK", comment: ""), style: .default, handler: { _ in
            completionHandler()
        }))
        self.present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController.alertController(
            title: .none,
            message: message,
            style: .alert,
            in: navigationController!
        )
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", value: "OK", comment: ""), style: .default, handler: { _ in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", value: "Cancel", comment: ""), style: .default, handler: { _ in
            completionHandler(false)
        }))
        self.present(alertController, animated: true, completion: nil)
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController.alertController(
            title: .none,
            message: prompt,
            style: .alert,
            in: navigationController!
        )
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", value: "OK", comment: ""), style: .default, handler: { _ in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Cancel", value: "Cancel", comment: ""), style: .default, handler: { _ in
            completionHandler(nil)
        }))
        self.present(alertController, animated: true, completion: nil)
    }
}

extension BrowserViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let command = DappAction.fromMessage(message) else { return }
        let action = DappAction.fromCommand(command)

        delegate?.didCall(action: action, callbackID: command.id)
    }
}

extension BrowserViewController: BrowserErrorViewDelegate {
    func didTapReload(_ sender: Button) {
        reload()
    }
}
