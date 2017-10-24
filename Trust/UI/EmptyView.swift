// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StatefulViewController

class EmptyView: UIView {

    let titleLabel = UILabel()
    let imageView = UIImageView()
    let button = Button(size: .normal, style: .solid)
    let insets: UIEdgeInsets
    var onRetry: (() -> Void)? = .none

    init(
        title: String = NSLocalizedString("Generic.Empty", value: "Empty", comment: ""),
        image: UIImage? = .none,
        insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
        onRetry: (() -> Void)? = .none
    ) {
        self.insets = insets
        self.onRetry = onRetry
        super.init(frame: .zero)

        backgroundColor = .white

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        titleLabel.textColor = Colors.lightBlack

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Generic.Refresh", value: "Refresh", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [titleLabel, imageView, button])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 10

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 160),
        ])
    }

    func retry() {
        onRetry?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EmptyView: StatefulPlaceholderView {
    func placeholderViewInsets() -> UIEdgeInsets {
        return insets
    }
}
