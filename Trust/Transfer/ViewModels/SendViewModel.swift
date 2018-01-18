// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct SendViewModel {

    let transferType: TransferType
    let config: Config

    init(
        transferType: TransferType,
        config: Config
    ) {
        self.transferType = transferType
        self.config = config
    }

    var title: String {
        return "Send \(symbol)"
    }

    var symbol: String {
        return transferType.symbol(server: config.server)
    }

    var contract: String {
        return transferType.contract()
    }

    var backgroundColor: UIColor {
        return .white
    }
}
