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

        let titlesStackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        titlesStackView.translatesAutoresizingMaskIntoConstraints = false
        titlesStackView.axis = .vertical
        titlesStackView.distribution = .fillProportionally
        titlesStackView.spacing = 8

        let rightStackView = UIStackView(arrangedSubviews: [amountLabel])
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.axis = .vertical

        let stackView = UIStackView(arrangedSubviews: [
            statusImageView,
            titlesStackView,
            rightStackView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.distribution = .fill

        statusImageView.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        subTitleLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        subTitleLabel.setContentCompressionResistancePriority(.required, for: .vertical)

        statusImageView.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        amountLabel.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
        amountLabel.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
        stackView.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            statusImageView.widthAnchor.constraint(lessThanOrEqualToConstant: 26),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: StyleLayout.sideMargin),
            stackView.trailingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leadingAnchor),
        ])

        separatorInset = UIEdgeInsets(
            top: 0,
            left: TransactionsLayout.tableView.layoutInsets.left - contentView.layoutInsets.left - layoutInsets.left,
            bottom: 0, right: 0
        )
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

        amountLabel.text = viewModel.amountText
        amountLabel.font = viewModel.amountFont
        amountLabel.textColor = viewModel.amountTextColor

        backgroundColor = viewModel.backgroundColor
    }
}
