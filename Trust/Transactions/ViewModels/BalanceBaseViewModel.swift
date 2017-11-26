// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BalanceBaseViewModel {
    var attributedCurrencyAmount: NSAttributedString? { get }
    var attributedAmount: NSAttributedString { get }
}

extension BalanceBaseViewModel {
    var largeLabelAttributed: [NSAttributedStringKey: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return [
            .font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold),
            .foregroundColor: Colors.lightBlack,
            .paragraphStyle: style,
        ]
    }

    var smallLabelAttributes: [NSAttributedStringKey: Any] {
        let style = NSMutableParagraphStyle()
        style.alignment = NSTextAlignment.center
        return [
            .font: UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular),
            .foregroundColor: Colors.darkGray,
            .paragraphStyle: style,
        ]
    }
}
