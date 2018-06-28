// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class PassphraseBackgroundShadow: UIView {
    init() {
        super.init(frame: .zero)
        backgroundColor = Colors.veryVeryLightGray
        layer.borderColor = Colors.veryLightGray.cgColor
        layer.borderWidth = 1
        layer.masksToBounds = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
