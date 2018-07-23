// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct ConfigExplorer {

    let server: RPCServer

    init(
        server: RPCServer
    ) {
        self.server = server
    }

    func transactionURL(for ID: String) -> URL? {
        guard let endpoint = explorer(for: server) else { return .none }
        let urlString: String? = {
            switch server {
            case .main:
                return endpoint + "/tx/" + ID
            case .classic:
                return endpoint + "/tx/" + ID
            case .poa:
                return endpoint + "/txid/search/" + ID
            case .callisto:
                return endpoint + "/tx/" + ID
            case .gochain:
                return endpoint + "/tx/" + ID
            }
        }()
        guard let string = urlString else { return .none }
        return URL(string: string)!
    }

    private func explorer(for server: RPCServer) -> String? {
        switch server {
        case .main:
            return "https://etherscan.io"
        case .classic:
            return "https://gastracker.io"
        case .poa:
            return "https://poaexplorer.com"
        case .callisto:
            return "https://explorer.callisto.network"
        case .gochain:
            return "https://explorer.gochain.io"
        }
    }
}
