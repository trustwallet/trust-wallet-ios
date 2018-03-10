// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StatefulViewController

class BookmarksEmptyView: UIView {

    let titleLabel = UILabel()
    let imageView = UIImageView()
    let insets: UIEdgeInsets
    private let viewModel = StateViewModel()

    init(
        title: String = NSLocalizedString("bookmarks.noBookmarks.label.title", value: "No bookmarks!", comment: ""),
        image: UIImage? = R.image.no_transactions_mascot(),
        insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) {
        self.insets = insets
        super.init(frame: .zero)

        titleLabel.text = title
        titleLabel.font = viewModel.descriptionFont
        titleLabel.textColor = viewModel.descriptionTextColor

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image

        backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 30

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

extension BookmarksEmptyView: StatefulPlaceholderView {
    func placeholderViewInsets() -> UIEdgeInsets {
        return insets
    }
}
