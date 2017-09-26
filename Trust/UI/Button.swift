// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

enum ButtonSize: Int {
    case normal
    case large
    case extraLarge

    var height: CGFloat {
        switch self {
        case .normal: return 44
        case .large: return 50
        case .extraLarge: return 64
        }
    }
}

enum ButtonStyle: Int {
    case solid
    case squared
    case border
    case borderless

    var backgroundColor: UIColor {
        switch self {
        case .solid, .squared: return Colors.blue
        case .border, .borderless: return .white
        }
    }

    var cornerRadius: CGFloat {
        switch self {
        case .solid, .border: return 5
        case .squared, .borderless: return 0
        }
    }

    var textColor: UIColor {
        switch self {
        case .solid, .squared: return .white
        case .border, .borderless: return Colors.blue
        }
    }

    var borderColor: UIColor {
        switch self {
        case .solid, .squared, .border: return Colors.blue
        case .borderless: return .clear
        }
    }

    var borderWidth: CGFloat {
        switch self {
        case .solid, .squared, .borderless: return 0
        case .border: return 1
        }
    }
}

class Button: UIButton {

    init(size: ButtonSize, style: ButtonStyle) {
        super.init(frame: .zero)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: size.height),
        ])

        backgroundColor = style.backgroundColor
        layer.cornerRadius = style.cornerRadius
        layer.borderColor = style.borderColor.cgColor
        layer.borderWidth = style.borderWidth
        titleLabel?.textColor = style.textColor
        setTitleColor(style.textColor, for: .normal)
        titleEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 5, right: 15)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
