// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct ConfirmPaymentViewModel {

    let type: ConfirmType

    init(type: ConfirmType) {
        self.type = type
    }

    var title: String {
        return NSLocalizedString("confirmPayment.confirm.button.title", value: "Confirm", comment: "")
    }

    var actionButtonText: String {
        switch type {
        case .sign:
            return NSLocalizedString("Approve", value: "Approve", comment: "")
        case .signThenSend:
            return NSLocalizedString("Send", value: "Send", comment: "")
        }
    }

    var insufficientFundText: String {
        return NSLocalizedString("send.error.insufficientFund", value: "Insufficient Fund", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }
}
