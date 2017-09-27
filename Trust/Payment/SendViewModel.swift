// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct SendViewModel {

    let transferType: TransferType

    init(transferType: TransferType) {
        self.transferType = transferType
    }

    var title: String {
        return "Send \(transferType.symbol)"
    }

    var backgroundColor: UIColor {
        return .white
    }
}
