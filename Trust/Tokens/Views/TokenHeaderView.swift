// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class TokenHeaderView: UIView {

    lazy var amountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = Colors.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var imageView: TokenImageView = {
        let imageView = TokenImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var buttonsView: TransactionsFooterView = {
        let footerView = TransactionsFooterView(
            frame: .zero,
            bottomOffset: 5
        )
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.setBottomBorder()
        return footerView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = UIStackView(arrangedSubviews: [
            .spacer(height: StyleLayout.sideMargin * 2),
            imageView,
            .spacer(height: 10),
            amountLabel,
            .spacer(height: 10),
            buttonsView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            buttonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: trailingAnchor),

            imageView.heightAnchor.constraint(equalToConstant: 84),
            imageView.widthAnchor.constraint(equalToConstant: 84),
        ])

        backgroundColor = Colors.veryVeryLightGray
        buttonsView.backgroundColor = Colors.veryVeryLightGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
