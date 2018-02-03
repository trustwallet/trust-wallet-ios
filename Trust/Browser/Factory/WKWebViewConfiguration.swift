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
        let callbacks = {};
        function addCallback(id, cb, isRPC = true) {
            callbacks[id] = {cb, isRPC}
        }

        function executeCallback(id, error, value) {
            console.log("executeCallback")
            console.log("id", id)
            console.log("value", value)
            console.log("error", error)
            console.log("error", error)

            let callback = callbacks[id].cb
            if (callbacks[id].isRPC) {
                if (error) {
                    let response = {"id": id, jsonrpc: "2.0", result: null, error: {message: error}}
                    callback(response, null)
                } else {
                    let response = {"id": id, jsonrpc: "2.0", result: value}
                    callback(null, response)
                }
            } else {
                callback(error, value)
            }

            delete callbacks[id]
        }

        function sendTransaction(request, cb) {
            let tx = request.params[0]
            console.log("here." + tx)
            let id = request.id || 8888
            addCallback(id, cb)
            webkit.messageHandlers.sendTransaction.postMessage({"name": "sendTransaction", "object": tx, id: id})
        }

        function signTransaction(tx, cb) {
            console.log("here2.", tx)
            let id = request.id || 8888
            addCallback(id, cb)
            webkit.messageHandlers.signTransaction.postMessage({"name": "signTransaction", "object": tx, id: id})
        }

        function signPersonalMessage(request, cb) {
            let message = {data: request.params[0]}
            let id = request.id || 8888
            console.log("here.5", cb)
            addCallback(id, cb)
            webkit.messageHandlers.signPersonalMessage.postMessage({"name": "signPersonalMessage", "object": message, id: id})
        }

        var web3 = new Web3();
        let trustProvider = new web3.providers.HttpProvider("\(session.config.rpcURL.absoluteString)")
        let provider = new web3.providers.HttpProvider("\(session.config.rpcURL.absoluteString)")
        web3.setProvider(trustProvider);
        window.web3 = web3

        web3.eth.defaultAccount = "\(address)"
        web3.version.getNetwork = function(cb) {
            cb(null, "\(session.config.chainID)")
        }
        web3.eth.getCoinbase = function(cb) {
            return cb(null, "\(address)")
        }
        web3.eth.sendTransaction = function(transaction, cb) {
            console.log("transaction", transaction)
            let id = 99999
            addCallback(id, cb, false)
            webkit.messageHandlers.sendTransaction.postMessage({"name": "sendTransaction", "object": transaction, id: id})
        }

        function response(request, result) {
            return {"id": request.id, "jsonrpc": request.jsonrpc, "result": result}
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
                    sendTransaction(request, cb)
                    break
                case "eth_coinbase":
                    cb(null, response(request, "\(address)"))
                    break
                case "eth_sign":
                    signPersonalMessage(request, cb)
                    break
                case "personal_sign":
                    signPersonalMessage(request, cb)
                    break
                default:
                    console.log("sendAsync return", request);
                    provider.sendAsync(request, cb)
                    break
            }
        }

        trustProvider.send = function(request) {
            console.log("send", request);

            switch (request.method) {
                case "net_listening":
                    return true
                case "net_version":
                    return response(request, "\(session.config.chainID)")
                case "eth_accounts":
                    return response(request, ["\(address)"])
                case "eth_coinbase":
                    return response(request, "\(address)")
                default:
                    console.log("send return", request.method);
                    return provider.send(request)
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
