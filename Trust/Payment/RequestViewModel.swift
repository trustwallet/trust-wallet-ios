// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit

struct RequestViewModel {

    let transferType: TransferType

    init(transferType: TransferType) {
        self.transferType = transferType
    }

    var title: String {
        switch transferType {
        case .ether: return "Request ETH"
        case .token(let token): return "Request \(token.name)"
        }
    }

    var backgroundColor: UIColor {
        return .white
    }
}
