// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

func applyStyle() {
    UINavigationBar.appearance().isTranslucent = false

    UINavigationBar.appearance().tintColor = Colors.blue

    UINavigationBar.appearance().titleTextAttributes = [
        NSForegroundColorAttributeName: Colors.black,
    ]

    BalanceTitleView.appearance().titleColor = Colors.black
    BalanceTitleView.appearance().titleFont = UIFont.systemFont(ofSize: 17, weight: UIFontWeightSemibold)
}

struct Colors {
    static let darkBlue = UIColor(hex: "1E76CE")
    static let blue = UIColor(hex: "2e91db")
    static let red = UIColor(hex: "f7506c")
    static let green = UIColor(hex: "2fbb4f")
    static let lightGray = UIColor.lightGray
    static let gray = UIColor.gray
    static let black = UIColor(hex: "313849")
    static let lightBlack = UIColor(hex: "313849")
}

struct Layout {
    static let sideMargin: CGFloat = 15
}
