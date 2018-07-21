// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustCore

struct ImageURLFormatter {

    func image(for coin: Coin) -> String {
        return Constants.images + "/coins/\(coin.rawValue).png"
    }

    func image(for contract: String) -> String {
        return Constants.images + "/tokens/\(contract.lowercased()).png"
    }
}
