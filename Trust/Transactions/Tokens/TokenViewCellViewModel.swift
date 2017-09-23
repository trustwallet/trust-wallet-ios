// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit

struct TokenViewCellViewModel {

    let token: Token

    init(token: Token) {
        self.token = token
    }

    var title: String {
        return token.name
    }

    var amount: String {
        return "\(token.balance)"
    }

    var amountTextColor: UIColor {
        return Colors.black
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: UIFontWeightMedium)
    }

    var subTitle: String {
        return token.symbol
    }

    var subTitleTextColor: UIColor {
        return Colors.gray
    }

    var subTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 12, weight: UIFontWeightThin)
    }

    var backgroundColor: UIColor {
        return .white
    }
}
