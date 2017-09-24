// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit

struct TokenViewCellViewModel {

    static let numberFormatter: NumberFormatter = {
        let numberFormatter = NumberFormatter()
        numberFormatter.minimumFractionDigits = 3
        numberFormatter.maximumFractionDigits = 3
        return numberFormatter
    }()

    let token: Token

    init(token: Token) {
        self.token = token
    }

    var title: String {
        return token.name
    }

    var amount: String {
        //Hack. Improve this part of the code
        var value = String(token.balance)
        value.insert(".", at: value.index(value.endIndex, offsetBy: -Int(token.decimals)))
        let double = NSNumber(value: Double(value) ?? 0)
        return TokenViewCellViewModel.numberFormatter.string(from: double)!
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
        return Colors.black
    }

    var subTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 13, weight: UIFontWeightRegular)
    }

    var backgroundColor: UIColor {
        return .white
    }

    var image: UIImage? {
        return R.image.ethereumToken()
    }
}
