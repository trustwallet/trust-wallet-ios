// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class TransactionViewCell: UITableViewCell {

    static let identifier = "TransactionTableViewCell"

    let statusImageView = UIImageView()
    let titleLabel = UILabel()
    let amountLabel = UILabel()
    let subTitleLabel = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        statusImageView.translatesAutoresizingMaskIntoConstraints = false
        statusImageView.contentMode = .scaleAspectFit

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.lineBreakMode = .byTruncatingMiddle

        amountLabel.textAlignment = .right
        amountLabel.translatesAutoresizingMaskIntoConstraints = false

        let leftStackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.axis = .vertical
        leftStackView.spacing = 6

        let rightStackView = UIStackView(arrangedSubviews: [amountLabel])
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.axis = .vertical

        let stackView = UIStackView(arrangedSubviews: [statusImageView, leftStackView, rightStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fill

        statusImageView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        subTitleLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)

        amountLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        stackView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            statusImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 44),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: StyleLayout.sideMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -StyleLayout.sideMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: StyleLayout.sideMargin),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: TransactionCellViewModel) {

        statusImageView.image = viewModel.statusImage

        titleLabel.text = viewModel.title

        subTitleLabel.text = viewModel.subTitle
        subTitleLabel.textColor = viewModel.subTitleTextColor
        subTitleLabel.font = viewModel.subTitleFont

        amountLabel.text = viewModel.amount
        amountLabel.textColor = viewModel.amountTextColor
        amountLabel.font = viewModel.amountFont

        backgroundColor = viewModel.backgroundColor
    }
}
