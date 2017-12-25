// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct ConfirmPaymentViewModel {

    var title: String {
        return NSLocalizedString("confirmPayment.confirm.button.title", value: "Confirm", comment: "")
    }

    var sendButtonText: String {
        return NSLocalizedString("Send", value: "Send", comment: "")
    }

    var backgroundColor: UIColor {
        return .white
    }
}
