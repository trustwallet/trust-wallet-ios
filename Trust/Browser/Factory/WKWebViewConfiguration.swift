// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import WebKit
import JavaScriptCore

extension WKWebViewConfiguration {

    static func make(for session: WalletSession, in messageHandler: WKScriptMessageHandler) -> WKWebViewConfiguration {
        let address = session.account.address.description.lowercased()
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
            if (error) {
                let response = {"id": id, jsonrpc: "2.0", result: null, error: {message: error}}
                callbacks[id](error, null)
            } else {
                let response = {"id": id, jsonrpc: "2.0", result: value}
                callbacks[id](error, response)
            }
        }

        function sendTransaction(tx, cb) {
            console.log("here." + tx)
            let id = addCallback(cb)
            webkit.messageHandlers.sendTransaction.postMessage({"name": "sendTransaction", "object": tx, id: id})
        }

        function signTransaction(tx, cb) {
            console.log("here2.", tx)
            let id = addCallback(cb)
            webkit.messageHandlers.signTransaction.postMessage({"name": "signTransaction", "object": tx, id: id})
        }

        function signPersonalMessage(message, cb) {
            console.log("here.5", cb)
            let id = addCallback(cb)
            webkit.messageHandlers.signPersonalMessage.postMessage({"name": "signPersonalMessage", "object": message, id: id})
        }

        var web3 = new Web3();
        let trustProvider = new web3.providers.HttpProvider("\(session.config.rpcURL.absoluteString)")
        let provider = new web3.providers.HttpProvider("\(session.config.rpcURL.absoluteString)")
        web3.setProvider(trustProvider);
        window.web3 = web3

        web3.eth.defaultAccount = "\(address)"
        web3.version.getNetwork = function(p) {
            p(null, "\(session.config.chainID)")
        }
        web3.eth.getCoinbase = function(p) {
            return p(null, "\(address)")
        }
        web3.eth.sendTransaction = function(p, cb) {
            sendTransaction(p, cb)
        }

        function response(p, result) {
            return {"id": p.id, "jsonrpc": p.jsonrpc, "result": result}
        }

        trustProvider.sendAsync = function(request, cb) {
            console.log("sendAsync ", request);

            switch (request.method) {
                case "net_listening":
                    cb(null, response(request, true))
                    break;
                case "net_version":
                    cb(null, response(request, "\(session.config.chainID)"))
                    break;
                case "eth_accounts":
                    cb(null, response(request, ["\(address)"]))
                    break;
                case "eth_sendTransaction":
                    sendTransaction(request.params[0], cb)
                    break
                case "eth_coinbase":
                    cb(null, response(request, "\(address)"))
                    break
                case "eth_sign":
                    signPersonalMessage(request.params[0], cb)
                    break
                case "personal_sign":
                    signPersonalMessage({data: request.params[0]}, cb)
                    break
                default:
                    console.log("sendAsync return", request.method);
                    provider.sendAsync(request, cb)
                    break
            }
        }

        trustProvider.send = function(p) {
            console.log("send", p);

            switch (p.method) {
                case "net_listening":
                    return true
                case "net_version":
                    return response(p, "\(session.config.chainID)")
                case "eth_accounts":
                    return response(p, ["\(address)"])
                case "eth_coinbase":
                    return response(p, "\(address)")
                default:
                    console.log("send return", p.method);
                    return provider.send(p)
            }
        }

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
