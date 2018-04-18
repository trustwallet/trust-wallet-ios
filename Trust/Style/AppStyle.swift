// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum AppStyle {
    case heading
    case paragraph
    case largeAmount

    var font: UIFont {
        switch self {
        case .heading:
            return UIFont.systemFont(ofSize: 18, weight: .medium)
        case .paragraph:
            return UIFont.systemFont(ofSize: 15, weight: .light)
        case .largeAmount:
            return UIFont.systemFont(ofSize: 20, weight: .medium)
        }
    }

    var textColor: UIColor {
        switch self {
        case .heading:
            return Colors.black
        case .paragraph:
            return Colors.charcoal
        case .largeAmount:
            return UIColor.black // Usually colors based on the amount
        }
    }
}
