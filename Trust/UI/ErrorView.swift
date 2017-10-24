// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StatefulViewController

class ErrorView: UIView {

    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let imageView = UIImageView()
    let button = Button(size: .normal, style: .solid)
    let insets: UIEdgeInsets

    var onRetry: (() -> Void)? = .none

    init(
        title: String = NSLocalizedString("errorView.titleLabel", value: "Oops!", comment: ""),
        description: String = NSLocalizedString("errorView.descriptionLabel", value: "Something went wrong... Try again.", comment: ""),
        image: UIImage? = .none,
        insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
        onRetry: (() -> Void)? = .none
    ) {
        self.onRetry = onRetry
        self.insets = insets
        super.init(frame: .zero)

        backgroundColor = .white

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: UIFontWeightMedium)
        titleLabel.textColor = Colors.lightBlack

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.text = description
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)
        descriptionLabel.textColor = Colors.gray

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Generic.Retry", value: "Retry", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            titleLabel,
            imageView,
            descriptionLabel,
            .spacer(),
            button,
        ])
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

extension ErrorView: StatefulPlaceholderView {
    func placeholderViewInsets() -> UIEdgeInsets {
        return insets
    }
}
