// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct WelcomeViewModel {

    var title: String {
        return "Welcome"
    }

    var backgroundColor: UIColor {
        return .white
    }

    var pageTitleFont: UIFont {
        return UIFont.systemFont(ofSize: 23, weight: UIFont.Weight.medium)
    }

    var pageTitleColor: UIColor {
        return UIColor(hex: "438FCA")
    }

    var pageDescriptionFont: UIFont {
        return UIFont.systemFont(ofSize: 15)
    }

    var pageDescriptionColor: UIColor {
        return UIColor(hex: "69A5D5")
    }

    var pageIndicatorTintColor: UIColor {
        return UIColor(hex: "c3dbee")
    }

    var currentPageIndicatorTintColor: UIColor {
        return UIColor(hex: "438FCA")
    }
}
