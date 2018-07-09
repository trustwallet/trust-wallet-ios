// Copyright DApps Platform Inc. All rights reserved.

import UIKit

final class TransactionViewCell: UITableViewCell {

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
        stackView.spacing = TransactionStyleLayout.stackViewSpacing
        stackView.distribution = .fill

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            statusImageView.widthAnchor.constraint(lessThanOrEqualToConstant: TransactionStyleLayout.preferedImageSize),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: StyleLayout.sideCellMargin),
            stackView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -StyleLayout.sideCellMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -StyleLayout.sideMargin),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateSeparatorInset()
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

    private func updateSeparatorInset() {
        separatorInset = UIEdgeInsets(
            top: 0,
            left: layoutInsets.left + StyleLayout.sideCellMargin + TransactionStyleLayout.preferedImageSize + TransactionStyleLayout.stackViewSpacing,
            bottom: 0, right: 0
        )
    }
}
