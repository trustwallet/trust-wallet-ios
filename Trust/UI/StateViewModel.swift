// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct StateViewModel {

    var titleTextColor: UIColor {
        return UIColor(hex: "438FCA")
    }

    var titleFont: UIFont {
        return UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
    }

    var descriptionTextColor: UIColor {
        return UIColor(hex: "69A5D5")
    }

    var descriptionFont: UIFont {
        return UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.regular)
    }

    var stackSpacing: CGFloat {
        return 30
    }
}
