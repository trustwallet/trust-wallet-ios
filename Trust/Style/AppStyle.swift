// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka

func applyStyle() {

    if #available(iOS 11, *) {
    } else {
        UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).isTranslucent = false
    }
    UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).tintColor = AppStyle.navigationBarTintColor
    UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).barTintColor = Colors.darkBlue

    UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).titleTextAttributes = [
        .foregroundColor: UIColor.white,
    ]

    UITextField.appearance().tintColor = Colors.blue

    UIImageView.appearance().tintColor = Colors.lightBlue

    BalanceTitleView.appearance().titleTextColor = UIColor.white
    BalanceTitleView.appearance().subTitleTextColor = UIColor(white: 0.9, alpha: 1)

    BrowserNavigationBar.appearance().setBackgroundImage(.filled(with: .white), for: .default)
}

struct Colors {
    static let darkBlue = UIColor(hex: "3375BB")
    static let blue = UIColor(hex: "2e91db")
    static let red = UIColor(hex: "f7506c")
    static let veryLightRed = UIColor(hex: "FFF4F4")
    static let veryLightOrange = UIColor(hex: "FFECC9")
    static let green = UIColor(hex: "2fbb4f")
    static let lightGray = UIColor.lightGray
    static let veryLightGray = UIColor(hex: "F6F6F6")
    static let veryVeryLightGray = UIColor(hex: "fafafa") // P.S. Creative naming
    static let gray = UIColor.gray
    static let darkGray = UIColor(hex: "606060")
    static let black = UIColor(hex: "313849")
    static let lightBlack = UIColor(hex: "313849")
    static let lightBlue = UIColor(hex: "007aff")
}

struct AppStyle {
    static let navigationBarTintColor = UIColor.white
    static let docPickerNavigationBarTintColor = Colors.blue
    static let activityViewControllerNavigationBarText = UIColor.white
    static let activityViewControllerNavigationBarTintColor = Colors.darkBlue
}

struct StyleLayout {
    static let sideMargin: CGFloat = 15

    struct TableView {
        static let heightForHeaderInSection: CGFloat = 30
    }
}
