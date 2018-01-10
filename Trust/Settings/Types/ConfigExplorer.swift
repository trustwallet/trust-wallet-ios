// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ConfigExplorer {

    let server: RPCServer

    init(
        server: RPCServer
    ) {
        self.server = server
    }

    func transactionURL(for ID: String) -> URL {
        let endpoint = explorer(for: server)
        let urlString: String = {
            switch server {
            case .main:
                return endpoint + "/tx/" + ID
            case .classic:
                return endpoint + "/tx/" + ID
            case .kovan:
                return endpoint + "/tx/" + ID
            case .ropsten:
                return endpoint + "/tx/" + ID
            case .poa:
                return endpoint + "/txid/search/" + ID
            case .sokol:
                return endpoint + "/tx/" + ID
            }
        }()
        return URL(string: urlString)!
    }

    private func explorer(for server: RPCServer) -> String {
        switch server {
        case .main:
            return "https://etherscan.io"
        case .classic:
            return "https://gastracker.io"
        case .kovan:
            return "https://ropsten.etherscan.io"
        case .ropsten:
            return "https://ropsten.etherscan.io"
        case .poa:
            return "https://poaexplorer.com"
        case .sokol:
            return "http://testnet.oracles.org:4000"
        }
    }
}
