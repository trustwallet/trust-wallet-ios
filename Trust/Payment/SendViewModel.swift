// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct SendViewModel {

    let transferType: TransferType

    init(transferType: TransferType) {
        self.transferType = transferType
    }

    var title: String {
        switch transferType {
        case .ether: return "Send ETH"
        case .token(let token): return "Send \(token.name)"
        }
    }

    var backgroundColor: UIColor {
        return .white
    }
}
