// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct SendTransaction: Decodable {
    let from: String
    let to: String?
    let value: String?
    let gas: String?
    let gasPrice: String?
    let data: String?
    let nonce: String?
}
