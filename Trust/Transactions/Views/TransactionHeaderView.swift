// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

struct TransactionHeaderAppereance {
    static let amountFont = AppStyle.largeAmount.font
    static let monetaryFont = UIFont.systemFont(ofSize: 13, weight: .light)
    static let monetaryTextColor = TokensLayout.cell.fiatAmountTextColor
}

struct TransactionHeaderViewViewModel {
}

class TransactionHeaderView: UIView {

    let imageView = UIImageView()
    let amountLabel = UILabel()
    let monetaryAmountLabel = UILabel()

    override init(frame: CGRect = .zero) {

        super.init(frame: frame)

        imageView.translatesAutoresizingMaskIntoConstraints = false

        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textAlignment = .center
        amountLabel.font = TransactionHeaderAppereance.amountFont

        monetaryAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        monetaryAmountLabel.textAlignment = .center
        monetaryAmountLabel.font = TransactionHeaderAppereance.monetaryFont
        monetaryAmountLabel.textColor = TransactionHeaderAppereance.monetaryTextColor

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            .spacerWidth(),
            amountLabel,
            monetaryAmountLabel,
        ])
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: StyleLayout.sideMargin),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -StyleLayout.sideMargin),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
