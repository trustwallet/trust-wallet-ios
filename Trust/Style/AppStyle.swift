// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum AppStyle {
    case heading
    case headingSemiBold
    case paragraph
    case paragraphLight
    case paragraphSmall
    case largeAmount
    case error
    case formHeader
    case collactablesHeader

    var font: UIFont {
        switch self {
        case .heading:
            return UIFont.systemFont(ofSize: 18, weight: .regular)
        case .headingSemiBold:
            return UIFont.systemFont(ofSize: 18, weight: .semibold)
        case .paragraph:
            return UIFont.systemFont(ofSize: 15, weight: .regular)
        case .paragraphSmall:
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        case .paragraphLight:
            return UIFont.systemFont(ofSize: 15, weight: .light)
        case .largeAmount:
            return UIFont.systemFont(ofSize: 20, weight: .medium)
        case .error:
            return UIFont.systemFont(ofSize: 13, weight: .light)
        case .formHeader:
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        case .collactablesHeader:
            return UIFont.systemFont(ofSize: 21, weight: UIFont.Weight.regular)
        }
    }

    var textColor: UIColor {
        switch self {
        case .heading, .headingSemiBold:
            return Colors.black
        case .paragraph, .paragraphLight, .paragraphSmall:
            return Colors.charcoal
        case .largeAmount:
            return UIColor.black // Usually colors based on the amount
        case .error:
            return Colors.errorRed
        case .formHeader:
            return Colors.doveGray
        case .collactablesHeader:
            return Colors.lightDark
        }
    }
}
