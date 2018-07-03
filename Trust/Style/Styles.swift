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
    UINavigationBar.appearance(whenContainedInInstancesOf: [NavigationController.self]).barTintColor = AppGlobalStyle.barTintColor

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
    static let barTintColor = Colors.darkBlue
}

struct StyleLayout {
    static let sideMargin: CGFloat = 15
    static let sideCellMargin: CGFloat = 10

    struct TableView {
        static let heightForHeaderInSection: CGFloat = 30
        static let separatorColor = UIColor(hex: "d7d7d7")
    }

    struct CollectibleView {
        static let heightForHeaderInSection: CGFloat = 40
    }
}

struct EditTokenStyleLayout {
    static let preferedImageSize: CGFloat = 52
    static let sideMargin: CGFloat = 15
}

struct TransactionStyleLayout {
    static let stackViewSpacing: CGFloat = 15
    static let preferedImageSize: CGFloat = 26
}
