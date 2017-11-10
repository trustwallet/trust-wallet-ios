// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BalanceBaseViewModel {
    var attributedCurrencyAmount: NSAttributedString? { get }
    var attributedAmount: NSAttributedString { get }
}

extension BalanceBaseViewModel {
    var largeLabelAttributed: [String: AnyObject] {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return [
            NSFontAttributeName: UIFont.systemFont(ofSize: 18, weight: UIFontWeightSemibold),
            NSForegroundColorAttributeName: Colors.lightBlack,
            NSParagraphStyleAttributeName: style,
        ]
    }

    var smallLabelAttributes: [String: AnyObject] {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return [
            NSFontAttributeName: UIFont.systemFont(ofSize: 13, weight: UIFontWeightRegular),
            NSForegroundColorAttributeName: Colors.darkGray,
            NSParagraphStyleAttributeName: style,
        ]
    }
}
