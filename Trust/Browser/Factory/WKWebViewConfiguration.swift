// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import WebKit
import JavaScriptCore

extension WKWebViewConfiguration {

    static func make(for session: WalletSession, in messageHandler: WKScriptMessageHandler) -> WKWebViewConfiguration {
        let address = session.account.address.description.lowercased()
        let config = WKWebViewConfiguration()
        var js = ""
        if let filepath = Bundle.main.path(forResource: "trust", ofType: "js") {
            do {
                js += try String(contentsOfFile: filepath)
                    .replacingOccurrences(of: "\n", with: "\\n")
                    .replacingOccurrences(of: "\r", with: "")
                    .replacingOccurrences(of: "\\", with: "\\\\")
                    //.replacingOccurrences(of: "\'", with: "\\\'")
                    //.replacingOccurrences(of: "\"", with: "\\\"")
                NSLog("Loaded Trust in page provider")
            } catch {
                NSLog("Failed to load Trust in page provider")
            }
        } else {
            NSLog("Trust in page provider not found in bundle")
        }

        js +=
        """
        
        const addressHex = "\(address)
        const rpcURL = "\(session.config.rpcURL.absoluteString)"
        const chainID = "\(session.config.chainID)"
        
        function executeCallback (id, error, value) {
          Trust.executeCallback(id, error, value)
        }

        Trust.init(rpcURL, {
          getAccounts: function (cb) { cb(null, [addressHex]) },
          signTransaction: function (txParams, cb){
            console.log('signing a transaction', tx)
            let id = txParams.id || 8888
            Trust.addCallback(id, cb)
            webkit.messageHandlers.signTransaction.postMessage({"name": "signTransaction", "object": txParams, id: id})
          },
          signPersonalMessage: function (request, cb) {
            let message = {data: request.params[0]}
            let id = request.id || 8888
            console.log("signing a personal message", cb)
            Trust.addCallback(id, cb)
            webkit.messageHandlers.signPersonalMessage.postMessage({"name": "signPersonalMessage", "object": message, id: id})
          },
          publishTransaction: function (request, cb) {
            let tx = request.params[0]
            console.log("here." + tx)
            let id = request.id || 8888
            Trust.addCallback(id, cb, false)
            webkit.messageHandlers.sendTransaction.postMessage({"name": "sendTransaction", "object": tx, id: id})
          }
        })

        web3.setProvider = function () {
          console.debug('Trust Wallet - overrode web3.setProvider');
        }

        web3.eth.defaultAccount = addressHex

        web3.version.getNetwork = function(cb) {
            cb(null, chainID)
        }
        web3.eth.getCoinbase = function(cb) {
            return cb(null, addressHex)
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
