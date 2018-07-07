// Copyright DApps Platform Inc. All rights reserved.

import Foundation

struct ImageURLFormatter {

    func image(chainID: Int) -> String {
        return Constants.images + "/tokens/ethereum-\(chainID).png"
    }

    func image(for contract: String) -> String {
        return Constants.images + "/tokens/\(contract.lowercased()).png"
    }
}
