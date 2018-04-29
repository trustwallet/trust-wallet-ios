// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum AppStyle {
    case heading
    case headingSemiBold
    case paragraph
    case paragraphLight
    case largeAmount

    var font: UIFont {
        switch self {
        case .heading:
            return UIFont.systemFont(ofSize: 18, weight: .regular)
        case .headingSemiBold:
            return UIFont.systemFont(ofSize: 18, weight: .semibold)
        case .paragraph:
            return UIFont.systemFont(ofSize: 15, weight: .regular)
        case .paragraphLight:
            return UIFont.systemFont(ofSize: 15, weight: .light)
        case .largeAmount:
            return UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }

    var textColor: UIColor {
        switch self {
        case .heading, .headingSemiBold:
            return Colors.black
        case .paragraph, .paragraphLight:
            return Colors.charcoal
        case .largeAmount:
            return UIColor.black // Usually colors based on the amount
        }
    }
}
