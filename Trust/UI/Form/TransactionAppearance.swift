// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TransactionAppearance {

    static func divider(color: UIColor, alpha: Double) -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }

    static func item(title: String, subTitle: String, completion:((_ title: String, _ value: String, _ sender: UIView) -> Void)? = .none) -> UIView {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.textColor = Colors.gray

        let subTitleLabel = UILabel(frame: .zero)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.text = subTitle
        subTitleLabel.textAlignment = .left
        subTitleLabel.textColor = Colors.black
        subTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.light)
        subTitleLabel.adjustsFontSizeToFitWidth = true

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true

        UITapGestureRecognizer(addToView: stackView) {
            completion?(title, subTitle, stackView)
        }

        return stackView
    }
}
