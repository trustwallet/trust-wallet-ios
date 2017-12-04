// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct Config {

    struct Keys {
        static let chainID = "chainID"
        static let isCryptoPrimaryCurrency = "isCryptoPrimaryCurrency"
        static let isDebugEnabled = "isDebugEnabled"
    }

    let defaults: UserDefaults

    init(
        defaults: UserDefaults = UserDefaults.standard
    ) {
        self.defaults = defaults
    }

    var chainID: Int {
        get {
            let id = defaults.integer(forKey: Keys.chainID)
            guard id > 0 else { return RPCServer.main.chainID }
            return id
        }
        set { defaults.set(newValue, forKey: Keys.chainID) }
    }

    var isCryptoPrimaryCurrency: Bool {
        get { return defaults.bool(forKey: Keys.isCryptoPrimaryCurrency) }
        set { defaults.set(newValue, forKey: Keys.isCryptoPrimaryCurrency) }
    }

    var isDebugEnabled: Bool {
        get { return defaults.bool(forKey: Keys.isDebugEnabled) }
        set { defaults.set(newValue, forKey: Keys.isDebugEnabled) }
    }

    var server: RPCServer {
        return RPCServer(chainID: chainID)
    }

    var rpcURL: URL {
        let urlString: String = {
            switch server {
            case .main: return "https://mainnet.infura.io/llyrtzQ3YhkdESt2Fzrk"
            case .kovan: return "https://kovan.infura.io/llyrtzQ3YhkdESt2Fzrk"
            case .ropsten: return "https://ropsten.infura.io/llyrtzQ3YhkdESt2Fzrk"
            case .oraclesTest: return "http://testnet.oracles.org:8545"
            }
        }()
        return URL(string: urlString)!
    }

    var remoteURL: URL {
        let urlString: String = {
            switch server {
            case .main: return "https://api.trustwalletapp.com"
            case .kovan: return "https://kovan.trustwalletapp.com"
            case .ropsten: return "https://ropsten.trustwalletapp.com"
            case .oraclesTest: return "https://oracles.trustwalletapp.com"
            }
        }()
        return URL(string: urlString)!
    }

    var ethplorerURL: URL {
        return URL(string: "https://api.ethplorer.io/")!
    }
}
