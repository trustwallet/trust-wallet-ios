// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")

        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }

    convenience init(netHex: Int) {
        self.init(red: (netHex >> 16) & 0xff, green: (netHex >> 8) & 0xff, blue: netHex & 0xff)
    }

    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0

        var rgbValue: UInt64 = 0

        scanner.scanHexInt64(&rgbValue)

        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff

        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }

    static func random() -> UIColor {
        return UIColor(red: .random(), green: .random(), blue: .random(), alpha: 0.7)
    }

    static func randomPastelColor(withMixedColor mixColor: UIColor? = UIColor.white) -> UIColor {

        var red: CGFloat = .randomColor()
        var green: CGFloat = .randomColor()
        var blue: CGFloat = .randomColor()

        if let mixColor = mixColor {
            var mixRed: CGFloat = 0
            var mixGreen: CGFloat = 0
            var mixBlue: CGFloat = 0
            mixColor.getRed(&mixRed, green: &mixGreen, blue: &mixBlue, alpha: nil)
            red = (red + mixRed) / 2
            green = (green + mixGreen) / 2
            blue = (blue + mixBlue) / 2
        }

        return UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
