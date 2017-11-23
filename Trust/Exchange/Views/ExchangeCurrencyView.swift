// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ExchangeCurrencyView: UIView {

    let currencyLabel = UILabel()

    init() {
        super.init(frame: .zero)

        currencyLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(currencyLabel)

        NSLayoutConstraint.activate([
            currencyLabel.topAnchor.constraint(equalTo: topAnchor, constant: StyleLayout.sideMargin),
            currencyLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: StyleLayout.sideMargin),
            currencyLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -StyleLayout.sideMargin),
            currencyLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -StyleLayout.sideMargin),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
