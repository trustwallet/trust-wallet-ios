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

    var layoutGuide: UILayoutGuide {
        if #available(iOS 11, *) {
            return safeAreaLayoutGuide
        } else {
            return layoutMarginsGuide
        }
    }

    var layoutInsets: UIEdgeInsets {
        if #available(iOS 11, *) {
            return safeAreaInsets
        } else {
            return layoutMargins
        }
    }

    static func spacer(height: CGFloat = 1, backgroundColor: UIColor = .clear) -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalToConstant: height),
        ])
        return view
    }

    static func spacerWidth(_ width: CGFloat = 1, backgroundColor: UIColor = .clear, alpha: CGFloat = 1) -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = backgroundColor
        view.alpha = alpha

        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: width),
        ])

        return view
    }

    var centerRect: CGRect {
        return CGRect(x: self.bounds.midX, y: self.bounds.midY, width: 0, height: 0)
    }
}
