// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

enum DividerDirection {
    case vertical
    case horizontal
}

struct TransactionAppearance {

    static let spacing: CGFloat = 16

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
        titleStyle: AppStyle = .heading,
        subTitleStyle: AppStyle = .paragraphLight,
        subTitleMinimumScaleFactor: CGFloat  = 0.7,
        layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15),
        completion:((_ title: String, _ value: String, _ sender: UIView) -> Void)? = .none
    ) -> UIView {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = titleStyle.font
        titleLabel.textColor = titleStyle.textColor
        titleLabel.textAlignment = .left

        let subTitleLabel = UILabel(frame: .zero)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.text = subTitle
        subTitleLabel.font = subTitleStyle.font
        subTitleLabel.textColor = subTitleStyle.textColor
        subTitleLabel.textAlignment = .left
        subTitleLabel.numberOfLines = 1
        subTitleLabel.adjustsFontSizeToFitWidth = true
        subTitleLabel.minimumScaleFactor = subTitleMinimumScaleFactor
        subTitleLabel.lineBreakMode = .byTruncatingMiddle

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

    static func horizontalItem(views: [UIView], distribution: UIStackViewDistribution = .fillProportionally) -> UIView {
        let view = UIStackView(arrangedSubviews: views)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.distribution = distribution
        return view
    }

    static func oneLine(
        title: String,
        subTitle: String,
        titleStyle: AppStyle = .heading,
        subTitleStyle: AppStyle = .paragraphLight,
        layoutMargins: UIEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15),
        backgroundColor: UIColor = .clear,
        completion:((_ title: String, _ value: String, _ sender: UIView) -> Void)? = .none
    ) -> UIView {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = titleStyle.font
        titleLabel.textColor = titleStyle.textColor
        titleLabel.textAlignment = .left
        titleLabel.backgroundColor = backgroundColor

        let subTitleLabel = UILabel(frame: .zero)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.text = subTitle
        subTitleLabel.font = subTitleStyle.font
        subTitleLabel.textColor = subTitleStyle.textColor
        subTitleLabel.textAlignment = .right
        subTitleLabel.backgroundColor = backgroundColor

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 6
        stackView.layoutMargins = layoutMargins
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.addBackground(color: backgroundColor)

        UITapGestureRecognizer(addToView: stackView) {
            completion?(title, subTitle, stackView)
        }

        return stackView
    }
}

extension UIStackView {
    func addBackground(color: UIColor) {
        let subView = UIView(frame: bounds)
        subView.backgroundColor = color
        subView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subView, at: 0)
    }
}
