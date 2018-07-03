// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Kingfisher

class TokenViewCell: UITableViewCell {

    static let identifier = "TokenViewCell"

    let titleLabel = UILabel()
    let amountLabel = UILabel()
    let currencyAmountLabel = UILabel()
    let symbolImageView = TokenImageView()

    private struct Layout {
        static let stackVericalOffset: CGFloat = 10
        static let arrangedSubviewsOffset: CGFloat = 4
    }

    lazy var marketPrice: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var marketPercentageChange: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.lineBreakMode = .byTruncatingMiddle
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.7

        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        symbolImageView.contentMode = .scaleAspectFit

        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textAlignment = .right

        currencyAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyAmountLabel.textAlignment = .right

        let marketPriceStackView = UIStackView(arrangedSubviews: [
            marketPrice,
            marketPercentageChange,
        ])
        marketPriceStackView.translatesAutoresizingMaskIntoConstraints = false
        marketPriceStackView.alignment = .firstBaseline
        marketPriceStackView.distribution = .equalSpacing
        marketPriceStackView.spacing = Layout.arrangedSubviewsOffset

        let leftStackView = UIStackView(arrangedSubviews: [titleLabel, marketPriceStackView])
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.axis = .vertical
        leftStackView.spacing = 6
        leftStackView.alignment = .leading

        let rightStackView = UIStackView(arrangedSubviews: [amountLabel, currencyAmountLabel])
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.axis = .vertical
        rightStackView.spacing = Layout.arrangedSubviewsOffset

        let stackView = UIStackView(arrangedSubviews: [symbolImageView, leftStackView, rightStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 15
        stackView.alignment = .center

        symbolImageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

        rightStackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .horizontal)

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            symbolImageView.leadingAnchor.constraint(equalTo: self.layoutGuide.leadingAnchor, constant: Layout.stackVericalOffset),
            symbolImageView.widthAnchor.constraint(equalToConstant: TokensLayout.cell.imageSize),
            symbolImageView.heightAnchor.constraint(equalToConstant: TokensLayout.cell.imageSize),
            stackView.topAnchor.constraint(equalTo: self.topAnchor, constant: Layout.stackVericalOffset),
            stackView.trailingAnchor.constraint(equalTo: self.layoutGuide.trailingAnchor, constant: -Layout.stackVericalOffset),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -Layout.stackVericalOffset),
            stackView.leadingAnchor.constraint(equalTo: symbolImageView.leadingAnchor),
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateSeparatorInset()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(viewModel: TokenViewCellViewModel) {

        titleLabel.text = viewModel.title
        titleLabel.textColor = viewModel.titleTextColor
        titleLabel.font = viewModel.titleFont

        amountLabel.text = viewModel.amount
        amountLabel.textColor = TokensLayout.cell.amountTextColor
        amountLabel.font = viewModel.amountFont

        marketPrice.text = viewModel.marketPrice
        marketPrice.textColor = viewModel.marketPriceTextColor
        marketPrice.font = viewModel.marketPriceFont

        marketPercentageChange.text = viewModel.percentChange
        marketPercentageChange.textColor = viewModel.percentChangeColor
        marketPercentageChange.font = viewModel.percentChangeFont

        currencyAmountLabel.text = viewModel.currencyAmount
        currencyAmountLabel.textColor = TokensLayout.cell.currencyAmountTextColor
        currencyAmountLabel.font = viewModel.currencyAmountFont

        symbolImageView.kf.setImage(
            with: viewModel.imageUrl,
            placeholder: viewModel.placeholderImage
        )

        backgroundColor = viewModel.backgroundColor
    }

    private func updateSeparatorInset() {
        separatorInset = UIEdgeInsets(
            top: 0,
            left: self.layoutInsets.left + Layout.stackVericalOffset + TokensLayout.cell.imageSize + Layout.stackVericalOffset + Layout.arrangedSubviewsOffset,
            bottom: 0, right: 0
        )
    }
}
