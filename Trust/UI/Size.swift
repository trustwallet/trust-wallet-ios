// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

struct Size {
    static func scale(size: CGFloat) -> CGFloat {
        if UIScreen.main.scale == 3 {
            return size
        }
        return size * 0.90
    }
}
