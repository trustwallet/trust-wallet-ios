// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import WebKit
import JavaScriptCore

extension WKWebViewConfiguration {

    static func make(for session: WalletSession, in messageHandler: WKScriptMessageHandler) -> WKWebViewConfiguration {
        let address = session.account.address.description
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
            return cb(null, ["\(address)"])
        },
        rpcUrl: "\(session.config.rpcURL.absoluteString)",
        sendTransaction: function(tx, cb) {
            console.log("here." + tx)
            let id = addCallback(cb)
            webkit.messageHandlers.sendTransaction.postMessage({"name": "sendTransaction", "object": tx, id: id})
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
            }
        })
        engine.start()
        var web3 = new Web3(engine)
        window.web3 = web3
        web3.eth.accounts = ["\(address)"]
        web3.eth.getAccounts = function(cb) {
            return cb(null, ["\(address)"])
        }
        web3.eth.defaultAccount = "\(address)"
        """
        let userScript = WKUserScript(source: js, injectionTime: .atDocumentStart, forMainFrameOnly: false)
        config.userContentController.add(messageHandler, name: Method.sendTransaction.rawValue)
        config.userContentController.add(messageHandler, name: Method.signTransaction.rawValue)
        config.userContentController.add(messageHandler, name: Method.signPersonalMessage.rawValue)
        config.userContentController.add(messageHandler, name: Method.signMessage.rawValue)
        config.userContentController.addUserScript(userScript)
        return config
    }
}
