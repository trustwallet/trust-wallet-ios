// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

enum RPCServer {
    case main
    case poa
    case classic
    case callisto
    case gochain

    var id: String {
        switch self {
        case .main: return "ethereum"
        case .poa: return "poa"
        case .classic: return "classic"
        case .callisto: return "callisto"
        case .gochain: return "gochain"
        }
    }

    var chainID: Int {
        switch self {
        case .main: return 1
        case .poa: return 99
        case .classic: return 61
        case .callisto: return 820
        case .gochain: return 60
        }
    }

    var priceID: Address {
        switch self {
        case .main: return EthereumAddress(string: "0x000000000000000000000000000000000000003c")!
        case .poa: return EthereumAddress(string: "0x00000000000000000000000000000000000000AC")!
        case .classic: return EthereumAddress(string: "0x000000000000000000000000000000000000003D")!
        case .callisto: return EthereumAddress(string: "0x0000000000000000000000000000000000000334")!
        case .gochain: return EthereumAddress(string: "0x00000000000000000000000000000000000017aC")!
        }
    }

    var isDisabledByDefault: Bool {
        switch self {
        case .main: return false
        case .poa, .classic, .callisto, .gochain: return true
        }
    }

    var name: String {
        switch self {
        case .main: return "Ethereum"
        case .poa: return "POA Network"
        case .classic: return "Ethereum Classic"
        case .callisto: return "Callisto"
        case .gochain: return "GoChain"
        }
    }

    var displayName: String {
        return "\(self.name) (\(self.symbol))"
    }

    var symbol: String {
        switch self {
        case .main: return "ETH"
        case .classic: return "ETC"
        case .callisto: return "CLO"
        case .poa: return "POA"
        case .gochain: return "GO"
        }
    }

    var decimals: Int {
        return 18
    }

    var rpcURL: URL {
        let urlString: String = {
            switch self {
            case .main: return "https://mainnet.infura.io/llyrtzQ3YhkdESt2Fzrk"
            case .classic: return "https://web3.gastracker.io"
            case .callisto: return "https://clo-geth.0xinfra.com"
            case .poa: return "https://poa.infura.io"
            case .gochain: return "https://rpc.gochain.io"
            }
        }()
        return URL(string: urlString)!
    }

    var wssURL: URL {
        let urlString: String = {
            switch self {
            case .main: return "wss://mainnet.infura.io/ws/llyrtzQ3YhkdESt2Fzrk"
            case .poa: return "wss://poa.infura.io"
            case .classic, .callisto, .gochain: return "wss://localhost"
            }
        }()
        return URL(string: urlString)!
    }

    var remoteURL: URL {
        let urlString: String = {
            switch self {
            case .main: return "https://api.trustwalletapp.com"
            case .classic: return "https://classic.trustwalletapp.com"
            case .callisto: return "https://callisto.trustwalletapp.com"
            case .poa: return "https://poa.trustwalletapp.com"
            case .gochain: return "https://gochain.trustwalletapp.com"
            }
        }()
        return URL(string: urlString)!
    }

    var ensContract: EthereumAddress {
        // https://docs.ens.domains/en/latest/introduction.html#ens-on-ethereum
        switch self {
        case .main:
            return EthereumAddress(string: "0x314159265dd8dbb310642f98f50c066173c1259b")!
        case .classic, .poa, .callisto, .gochain:
            return EthereumAddress.zero
        }
    }

    var openseaPath: String {
        switch self {
        case .main, .classic, .poa, .callisto, .gochain: return Constants.dappsOpenSea
        }
    }

    var openseaURL: URL? {
        return URL(string: openseaPath)
    }

    func opensea(with contract: String, and id: String) -> URL? {
        return URL(string: (openseaPath + "/assets/\(contract)/\(id)"))
    }

    var coin: Coin {
        switch self {
        case .main: return Coin.ethereum
        case .classic: return Coin.ethereumClassic
        case .callisto: return Coin.callisto
        case .poa: return Coin.poa
        case .gochain: return Coin.gochain
        }
    }
}

extension RPCServer: Equatable {
    static func == (lhs: RPCServer, rhs: RPCServer) -> Bool {
        switch (lhs, rhs) {
        case (let lhs, let rhs):
            return lhs.chainID == rhs.chainID
        }
    }
}
