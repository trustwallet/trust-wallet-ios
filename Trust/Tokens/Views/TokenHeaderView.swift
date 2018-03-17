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

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var imageView: TokenImageView = {
        let imageView = TokenImageView()
        imageView.image = R.image.ethereum_logo_256()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    lazy var buttonsView: TransactionsFooterView = {
        let footerView = TransactionsFooterView(frame: .zero)
        footerView.translatesAutoresizingMaskIntoConstraints = false
        //footerView.setBottomBorder()
        return footerView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            amountLabel,
            buttonsView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: StyleLayout.sideMargin * 2),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            buttonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: trailingAnchor),

            imageView.heightAnchor.constraint(equalToConstant: 64),
            imageView.widthAnchor.constraint(equalToConstant: 64),
            //imageView.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
        ])

        backgroundColor = Colors.veryLightGray
        buttonsView.backgroundColor = Colors.veryLightGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
