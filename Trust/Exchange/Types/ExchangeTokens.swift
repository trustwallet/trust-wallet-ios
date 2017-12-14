// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ExchangeTokens {
    static func get(for server: RPCServer) -> [ExchangeToken] {
        switch server {
        case .main, .ropsten, .oracles, .oraclesTest:
            return [
                ExchangeToken(name: "Ethereum", address: Address(address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"), symbol: "ETH", image: R.image.token_eth(), decimals: 18),
            ]
        case .kovan:
            return [
                ExchangeToken(name: "Ethereum", address: Address(address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"), symbol: "ETH", image: R.image.token_eth(), decimals: 18),
                ExchangeToken(name: "OmiseGO", address: Address(address: "0xf26a8e0fa25fe9e750114e27a46777d49cb8063c"), symbol: "OMG", image: R.image.token_omg(), decimals: 18),
                //ExchangeToken(name: "DigixDAO", address: Address(address: "0x94dd60e21ea28c253259adabec45ecb7ccaaa1a2"), symbol: "DGD", image: R.image.token_dgd(), decimals: 9),
                //ExchangeToken(name: "Civic", address: Address(address: "0x561ef26735743ad6528d341e1ca6f4aaf1ab2482"), symbol: "CVC", image: R.image.token_cvc(), decimals: 8),
                //ExchangeToken(name: "FunFair", address: Address(address: "0x9e5d1d621ef8f8dc12edc405fa285df0df01027f"), symbol: "FUN", image: R.image.token_fun(), decimals: 18),
                //ExchangeToken(name: "Monaco", address: Address(address: "0xc8d025a88c838819d1a1a2bde1bf101db6b8cbf8"), symbol: "MCO", image: R.image.token_mco(), decimals: 18),
                ExchangeToken(name: "Golem", address: Address(address: "0x3b05f2285125b673f75d035f75598ba120149ab9"), symbol: "GNT", image: R.image.token_gnt(), decimals: 18),
                //ExchangeToken(name: "AdEx", address: Address(address: "0x66cd4fbe38c31094682b9b8cbe306efb4fde895f"), symbol: "ADX", image: R.image.token_a()),
                //ExchangeToken(name: "TenX", address: Address(address: "0xcccc987398f87cc3b14d29e951ba779e3a4b30b7"), symbol: "PAY", image: R.image.token_()),
                ExchangeToken(name: "Basic Attention Token", address: Address(address: "0x2cf1e1f23c8e3c55461a78b3d7ca106731c37861"), symbol: "BAT", image: R.image.token_bat(), decimals: 18),
                ExchangeToken(name: "Kyber Network", address: Address(address: "0x0461d6ad4be491449aed5cec70528c4d53e6f5de"), symbol: "KNC", image: R.image.token_knc(), decimals: 18),
                //ExchangeToken(name: "EOS", address: Address(address: "0x3dcb34be7215275b7036e4c3f16160ab28b1ed70"), symbol: "EOS", image: R.image.token_eos(), decimals: 18),
                //ExchangeToken(name: "ChainLink", address: Address(address: "0x9575de7d78fe1438864cc678539ea86d21b8c7c7"), symbol: "LINK", image: R.image.token_link(), decimals: 18),
            ]
        }
    }
}
