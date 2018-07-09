// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class PassphraseBackgroundShadow: UIView {
    init() {
        super.init(frame: .zero)

        let borderColor = Colors.lightGray
        let height: CGFloat = 0.5
        backgroundColor = Colors.veryVeryLightGray

        let topSeparator: UIView = .spacer(height: height, backgroundColor: borderColor, alpha: 0.3)
        let bottomSeparator: UIView = .spacer(height: height, backgroundColor: borderColor, alpha: 0.3)

        addSubview(topSeparator)
        addSubview(bottomSeparator)

        NSLayoutConstraint.activate([
            topSeparator.topAnchor.constraint(equalTo: topAnchor),
            topSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            topSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),

            bottomSeparator.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -height),
            bottomSeparator.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomSeparator.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
