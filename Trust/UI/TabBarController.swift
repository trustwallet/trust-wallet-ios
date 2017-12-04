// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class TabBarController: UITabBarController {

    var didShake: (() -> Void)?

    override func motionBegan(_ motion: UIEventSubtype, with event: UIEvent?) {
        didShake?()
    }
}
