// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class TokenHeaderView: UIView {

    private struct Layout {
        static let imageSize: CGFloat = 70
    }

    lazy var amountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = Colors.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var fiatAmountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = Colors.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var imageView: TokenImageView = {
        let imageView = TokenImageView(frame: .zero)
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

    lazy var container: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 0
        stackView.distribution = .equalSpacing
        stackView.alignment = .center
        return stackView
    }()

    let percentChange = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        fiatAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        fiatAmountLabel.textAlignment = .right

        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textAlignment = .right

        percentChange.translatesAutoresizingMaskIntoConstraints = false
        percentChange.textAlignment = .right

        let amountStack = UIStackView(arrangedSubviews: [amountLabel])
        amountStack.translatesAutoresizingMaskIntoConstraints = false
        amountStack.axis = .horizontal
        amountStack.spacing = 5

        let marketPriceStack = UIStackView(arrangedSubviews: [fiatAmountLabel, percentChange])
        marketPriceStack.translatesAutoresizingMaskIntoConstraints = false
        marketPriceStack.axis = .horizontal
        marketPriceStack.spacing = 5

        container.addArrangedSubview(.spacer(height: StyleLayout.sideMargin * 2))
        container.addArrangedSubview(imageView)
        container.addArrangedSubview(.spacer(height: 12))
        container.addArrangedSubview(amountLabel)
        container.addArrangedSubview(.spacer(height: 12))
        container.addArrangedSubview(marketPriceStack)
        container.addArrangedSubview(.spacer(height: 12))
        container.addArrangedSubview(buttonsView)

        addSubview(container)

        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            container.bottomAnchor.constraint(equalTo: bottomAnchor),

            buttonsView.leadingAnchor.constraint(equalTo: leadingAnchor),
            buttonsView.trailingAnchor.constraint(equalTo: trailingAnchor),

            imageView.heightAnchor.constraint(equalToConstant: Layout.imageSize),
            imageView.widthAnchor.constraint(equalToConstant: Layout.imageSize),
        ])

        backgroundColor = Colors.veryVeryLightGray
        buttonsView.backgroundColor = Colors.veryVeryLightGray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
