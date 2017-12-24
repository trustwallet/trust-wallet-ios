// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Kingfisher

class TokenViewCell: UITableViewCell {

    static let identifier = "TokenViewCell"

    let titleLabel = UILabel()
    let amountLabel = UILabel()
    let currencyAmountLabel = UILabel()
    let symbolImageView = UIImageView()
    let percentChange = UILabel()

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        symbolImageView.translatesAutoresizingMaskIntoConstraints = false
        symbolImageView.contentMode = .scaleAspectFit

        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textAlignment = .right

        currencyAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        currencyAmountLabel.textAlignment = .right
        
        percentChange.translatesAutoresizingMaskIntoConstraints = false
        percentChange.textAlignment = .right

        let leftStackView = UIStackView(arrangedSubviews: [titleLabel])
        leftStackView.translatesAutoresizingMaskIntoConstraints = false
        leftStackView.axis = .vertical
        leftStackView.spacing = 12
        
        let rightBottomStackView = UIStackView(arrangedSubviews: [currencyAmountLabel, percentChange])
        rightBottomStackView.translatesAutoresizingMaskIntoConstraints = false
        rightBottomStackView.axis = .horizontal
        rightBottomStackView.spacing = 5

        let rightStackView = UIStackView(arrangedSubviews: [amountLabel, rightBottomStackView])
        rightStackView.distribution = .fillEqually
        rightStackView.translatesAutoresizingMaskIntoConstraints = false
        rightStackView.axis = .vertical
        rightStackView.spacing =  5

        let stackView = UIStackView(arrangedSubviews: [symbolImageView, leftStackView, rightStackView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fill
        stackView.alignment = .center

        symbolImageView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)

        rightStackView.setContentHuggingPriority(.required, for: .horizontal)
        stackView.setContentHuggingPriority(.required, for: .horizontal)

        addSubview(stackView)

        NSLayoutConstraint.activate([
            symbolImageView.widthAnchor.constraint(equalToConstant: 50),
            symbolImageView.heightAnchor.constraint(equalToConstant: 50),
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
        titleLabel.textColor = viewModel.titleTextColor
        titleLabel.font = viewModel.titleFont

        amountLabel.text = viewModel.amount
        amountLabel.textColor = viewModel.amountTextColor
        amountLabel.font = viewModel.amountFont

        currencyAmountLabel.text = viewModel.currencyAmount
        currencyAmountLabel.textColor = viewModel.currencyAmountTextColor
        currencyAmountLabel.font = viewModel.currencyAmountFont
        
        percentChange.text = viewModel.percentChange
        percentChange.textColor = viewModel.percentChangeColor
        percentChange.font = viewModel.currencyAmountFont
        
        symbolImageView.kf.setImage(with:viewModel.imageUrl,placeholder:viewModel.placeHolder,options:
        [KingfisherOptionsInfoItem.fromMemoryCacheOrRefresh])

        backgroundColor = viewModel.backgroundColor
    }
}
