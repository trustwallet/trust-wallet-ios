// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ExchangeTokens {
    static func get(for server: RPCServer) -> [ExchangeToken] {
        switch server {
        case .main, .oraclesTest:
            return [
                ExchangeToken(name: "Ethereum", address: Address(address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"), symbol: "ETH", image: R.image.token_eth()),
            ]
        case .kovan:
            return [
                ExchangeToken(name: "Ethereum", address: Address(address: "0xeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee"), symbol: "ETH", image: R.image.token_eth()),
                ExchangeToken(name: "OmiseGO", address: Address(address: "0x6b662ffde8f1d2240eb4eefa211463be0eb258a1"), symbol: "OMG", image: R.image.token_omg()),
                ExchangeToken(name: "DigixDAO", address: Address(address: "0xd27763c026260bb8cfcf47a3d2ca18f03cb9da55"), symbol: "DGD", image: R.image.token_dgd()),
                ExchangeToken(name: "Civic", address: Address(address: "0x3d1bdb333d4bbd0bf84519c506c953ef869ef179"), symbol: "CVC", image: R.image.token_cvc()),
                ExchangeToken(name: "FunFair", address: Address(address: "0x0f679d211f23764c3020e2dca0d6277b9abb5b72"), symbol: "FUN", image: R.image.token_fun()),
                ExchangeToken(name: "Monaco", address: Address(address: "0xf596502b120689a119dd961b77426e6866e73d2a"), symbol: "MCO", image: R.image.token_mco()),
                ExchangeToken(name: "Golem", address: Address(address: "0x79c800440c5ebac80a8072e7659fa0c7c92da7df"), symbol: "GNT", image: R.image.token_gnt()),
                //ExchangeToken(name: "AdEx", address: Address(address: "0x66cd4fbe38c31094682b9b8cbe306efb4fde895f"), symbol: "ADX", image: R.image.token_a()),
                //ExchangeToken(name: "TenX", address: Address(address: "0xcccc987398f87cc3b14d29e951ba779e3a4b30b7"), symbol: "PAY", image: R.image.token_()),
                ExchangeToken(name: "Basic Attention Token", address: Address(address: "0x8726f7961b39c0a49501b943874ac92ed7240559"), symbol: "BAT", image: R.image.token_bat()),
                ExchangeToken(name: "Kyber Network", address: Address(address: "0xb4ac19f6495df29f32878182be06a2f0572f9763"), symbol: "KNC", image: R.image.token_knc()),
                ExchangeToken(name: "EOS", address: Address(address: "0x07ae1a78a58b01f077b3ca700d352a3db1e11392"), symbol: "EOS", image: R.image.token_eos()),
                ExchangeToken(name: "ChainLink", address: Address(address: "0x829e5df8ba4014021a3b3ba4232c54e9c17ddf70"), symbol: "LINK", image: R.image.token_link()),
            ]
        }
    }
}
