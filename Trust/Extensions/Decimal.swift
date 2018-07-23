// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

extension Decimal {
    var doubleValue: Double {
        return NSDecimalNumber(decimal: self).doubleValue
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
    static func randomColor() -> CGFloat {
        return CGFloat(arc4random() % 256 ) / 256
    }
}
