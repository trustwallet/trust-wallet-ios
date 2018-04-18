// Copyright SIX DAY LLC. All rights reserved.

import UIKit

enum AppStyle {
    case heading
    case paragraph

    var font: UIFont {
        switch self {
        case .heading:
            return UIFont.systemFont(ofSize: 18, weight: .medium)
        case .paragraph:
            return UIFont.systemFont(ofSize: 15, weight: .light)
        }
    }

    var textColor: UIColor {
        switch self {
        case .heading:
            return Colors.black
        case .paragraph:
            return Colors.charcoal
        }
    }
}
