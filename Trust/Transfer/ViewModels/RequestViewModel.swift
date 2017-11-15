// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct RequestViewModel {

    let transferType: TransferType
    let config: Config

    init(
        transferType: TransferType,
        config: Config
    ) {
        self.transferType = transferType
        self.config = config
    }

    var headlineTitle: String {
        switch config.server {
        case .main: return NSLocalizedString("request.headlineTitle", value: "My Ethereum Wallet Address", comment: "")
        case .kovan: return NSLocalizedString("request.headlineTitle", value: "My Ethereum Wallet Address", comment: "")
        case .oraclesTest: return NSLocalizedString("request.headlineTitle", value: "My Oracles Wallet Address", comment: "")
        }
    }

    var backgroundColor: UIColor {
        return .white
    }
}
