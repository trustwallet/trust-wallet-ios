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

    lazy var homeView: BrowserHomeView = {
        let homeView = BrowserHomeView()
        homeView.translatesAutoresizingMaskIntoConstraints = false
        homeView.delegate = self
        return homeView
    }()

    weak var delegate: BrowserViewControllerDelegate?
    private let urlParser = BrowserURLParser()
    let browserNavBar = BrowserNavigationBar()

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

        browserNavBar.translatesAutoresizingMaskIntoConstraints = false
        browserNavBar.browserDelegate = self
        view.addSubview(browserNavBar)

        view.addSubview(webView)
        injectUserAgent()

        view.addSubview(errorView)
        view.addSubview(homeView)

        NSLayoutConstraint.activate([
            browserNavBar.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            browserNavBar.heightAnchor.constraint(equalToConstant: 44),
            browserNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            browserNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            webView.topAnchor.constraint(equalTo: browserNavBar.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor),

            errorView.topAnchor.constraint(equalTo: webView.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: webView.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: webView.bottomAnchor),

            homeView.topAnchor.constraint(equalTo: view.topAnchor),
            homeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            homeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            homeView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
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

        if browserNavBar.alpha != 0 {
            navigationController?.setNavigationBarHidden(true, animated: false)
        }

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

    private func goHome() {
        guard let url = URL(string: Constants.dappsBrowserURL) else { return }
        hideErrorView()
        webView.load(URLRequest(url: url))
        browserNavBar.textField.text = url.absoluteString
    }

    private func reload() {
        hideErrorView()
        webView.reload()
    }

    private func stopLoading() {
        webView.stopLoading()
    }

    private func refreshURL() {
        browserNavBar.textField.text = webView.url?.absoluteString
    }

    private func reloadButtons() {
        browserNavBar.goBack.isEnabled = webView.canGoBack
        browserNavBar.goForward.isEnabled = webView.canGoForward
    }

    private func hideErrorView() {
        errorView.isHidden = true
    }

    private func showHomeView(_ show: Bool, animated: Bool = true) {
        let duration = animated ? 0.4 : 0
        UIView.animate(withDuration: duration, delay: 0.0, options: [], animations: {
            self.homeView.alpha = show ? 1 : 0
            self.browserNavBar.alpha = show ? 0 : 1
            if show {
                self.browserNavBar.textField.resignFirstResponder()
            } else {
                self.browserNavBar.textField.becomeFirstResponder()
            }
        })
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let change = change else { return }
        if context != &myContext {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        if keyPath == Keys.estimatedProgress {
            if let progress = (change[NSKeyValueChangeKey.newKey] as AnyObject).floatValue {
                browserNavBar.progressView.progress = progress
                browserNavBar.progressView.isHidden = progress == 1
            }
        } else if keyPath == Keys.URL {
            if let url = webView.url {
                self.browserNavBar.textField.text = url.absoluteString
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
        let addBookmarkAction = UIAlertAction(title: NSLocalizedString("browser.addbookmark.button.title", value: "Add Bookmark", comment: ""), style: .default) { [unowned self] _ in
            self.addBookmark()
        }
        let viewBookmarksAction = UIAlertAction(title: NSLocalizedString("browser.bookmarks.button.title", value: "Bookmarks", comment: ""), style: .default) { [unowned self] _ in
            self.showBookmarks()
        }

        alertController.addAction(homeAction)
        alertController.addAction(reloadAction)
        alertController.addAction(shareAction)
        alertController.addAction(addBookmarkAction)
        alertController.addAction(viewBookmarksAction)
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
            showHomeView(true)
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

extension BrowserViewController: BrowserHomeViewDelegate {
    func didPressQrCode() {
        //TODO: Scan QR Code - model view controller?
    }

    func didPressSearch() {
        showHomeView(false)
    }
}
