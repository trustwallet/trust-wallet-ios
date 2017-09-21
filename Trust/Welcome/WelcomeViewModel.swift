// Copyright SIX DAY LLC, Inc. All rights reserved.

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
        return UIFont.systemFont(ofSize: 22)
    }
    
    var pageTitleColor: UIColor {
        return Colors.black
    }
    
    var pageDescriptionFont: UIFont {
        return UIFont.systemFont(ofSize: 14)
    }
    
    var pageDescriptionColor: UIColor {
        return UIColor(hex: "848484")
    }
}
