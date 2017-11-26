// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class TokenViewCell: UITableViewCell {

    static let identifier = "TokenViewCell"

    let titleLabel = UILabel()
    let amountLabel = UILabel()
    let symbolImageView = UIImageView()
    let subTitleLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.lineBreakMode = .byTruncatingMiddle

        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        symbolImageView.contentMode = .scaleAspectFit

        amountLabel.textAlignment = .right
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        let leftStackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.axis = .vertical
        leftStackView.spacing = 2

        let rightStackView = UIStackView(arrangedSubviews: [amountLabel])
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.axis = .vertical

        let stackView = UIStackView(arrangedSubviews: [symbolImageView, leftStackView, rightStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fill

        symbolImageView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)

        amountLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        stackView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            symbolImageView.widthAnchor.constraint(equalToConstant: 40),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: StyleLayout.sideMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -StyleLayout.sideMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: StyleLayout.sideMargin),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: TokenViewCellViewModel) {
        titleLabel.text = viewModel.title

        amountLabel.text = viewModel.amount
        amountLabel.textColor = viewModel.amountTextColor
        amountLabel.font = viewModel.amountFont

        subTitleLabel.text = viewModel.subTitle
        subTitleLabel.textColor = viewModel.subTitleTextColor
        subTitleLabel.font = viewModel.subTitleFont

        symbolImageView.image = viewModel.image

        backgroundColor = viewModel.backgroundColor
    }
}
