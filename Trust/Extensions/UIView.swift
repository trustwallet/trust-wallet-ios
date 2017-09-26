// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

extension UIView {
    func anchor(to view: UIView, margin: CGFloat = 0) {
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: view.topAnchor, constant: margin),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -margin),
            bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -margin),
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: margin),
        ])
    }
}
