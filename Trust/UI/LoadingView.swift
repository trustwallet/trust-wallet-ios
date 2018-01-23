// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StatefulViewController

class LoadingView: UIView {

    let label = UILabel()
    let imageView = UIImageView()
    let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    let insets: UIEdgeInsets
    private let viewModel = StateViewModel()

    init(
        frame: CGRect = .zero,
        message: String = NSLocalizedString("Loading", value: "Loading", comment: ""),
        image: UIImage? = .none,
        insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    ) {
        self.insets = insets
        super.init(frame: frame)

        backgroundColor = .white

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = message
        label.font = viewModel.titleFont
        label.textColor = viewModel.titleTextColor

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image

        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.startAnimating()

        let stackView = UIStackView(arrangedSubviews: [
            loadingIndicator,
            label,
            imageView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = viewModel.stackSpacing

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension LoadingView: StatefulPlaceholderView {
    func placeholderViewInsets() -> UIEdgeInsets {
        return insets
    }
}
