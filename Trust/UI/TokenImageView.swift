// Copyright DApps Platform Inc. All rights reserved.

import UIKit

final class TokenImageView: UIImageView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2.0
        layer.borderColor = UIColor(hex: "dddddd").cgColor
        layer.borderWidth = 0.5
        layer.masksToBounds = false
        contentMode = .scaleAspectFit
        clipsToBounds = true
    }
}
