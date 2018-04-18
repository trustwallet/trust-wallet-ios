// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka

func applyStyle() {

    if #available(iOS 11, *) {
    } else {
        UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).isTranslucent = false
    }
    UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).tintColor = AppGlobalStyle.navigationBarTintColor
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

struct AppGlobalStyle {
    static let navigationBarTintColor = UIColor.white
    static let docPickerNavigationBarTintColor = Colors.darkBlue
    static let activityViewControllerNavigationBarText = UIColor.white
    static let activityViewControllerNavigationBarTintColor = Colors.darkBlue
}

struct StyleLayout {
    static let sideMargin: CGFloat = 15

    struct TableView {
        static let heightForHeaderInSection: CGFloat = 30
        static let separatorColor = UIColor(hex: "d7d7d7")
    }
}
