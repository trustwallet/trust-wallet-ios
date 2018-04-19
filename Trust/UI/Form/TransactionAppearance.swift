// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

enum DividerDirection {
    case vertical
    case horizontal
}

struct TransactionAppearance {

    static func divider(direction: DividerDirection = .horizontal, color: UIColor, alpha: CGFloat = 1, layoutInsets: UIEdgeInsets = .zero) -> UIView {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = color
        label.alpha = alpha

        switch direction {
        case .horizontal:
            label.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        case .vertical:
            label.widthAnchor.constraint(equalToConstant: 0.5).isActive = true
        }

        let stackView = UIStackView(arrangedSubviews: [label])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layoutMargins = layoutInsets
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }

    static func item(
        title: String,
        subTitle: String,
        layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15),
        completion:((_ title: String, _ value: String, _ sender: UIView) -> Void)? = .none
    ) -> UIView {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = AppStyle.heading.font
        titleLabel.textColor = AppStyle.heading.textColor
        titleLabel.textAlignment = .left

        let subTitleLabel = UILabel(frame: .zero)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.text = subTitle
        subTitleLabel.font = AppStyle.paragraph.font
        subTitleLabel.textColor = AppStyle.paragraph.textColor
        subTitleLabel.textAlignment = .left
        subTitleLabel.numberOfLines = 0

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true

        UITapGestureRecognizer(addToView: stackView) {
            completion?(title, subTitle, stackView)
        }

        return stackView
    }
}
