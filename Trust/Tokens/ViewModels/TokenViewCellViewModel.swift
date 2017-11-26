// Copyright SIX DAY LLC. All rights reserved.

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
        return token.amount
    }

    var amountTextColor: UIColor {
        return Colors.black
    }

    var amountFont: UIFont {
        return UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
    }

    var subTitle: String {
        return token.symbol
    }

    var subTitleTextColor: UIColor {
        return Colors.black
    }

    var subTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: UIFont.Weight.regular)
    }

    var backgroundColor: UIColor {
        return .white
    }

    var image: UIImage? {
        return R.image.ethereumToken()
    }
}
