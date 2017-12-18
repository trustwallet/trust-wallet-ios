// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct ERC20Contract: Decodable {
    let address: String
    let name: String
    let totalSupply: String
    let decimals: Int
    let symbol: String
}

struct LocalizedOperation: Decodable {
    let from: String
    let to: String
    let type: OperationType
    let value: String
    let contract: ERC20Contract

    enum CodingKeys: String, CodingKey {
        case from
        case to
        case type
        case value
        case contract
    }
}
