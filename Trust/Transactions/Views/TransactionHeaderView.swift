// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class TransactionHeaderView: UIView {

    let amountLabel = UILabel()
    let monetaryAmountLabel = UILabel()

    override init(frame: CGRect = .zero) {

        super.init(frame: frame)

        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.textAlignment = .center

        monetaryAmountLabel.translatesAutoresizingMaskIntoConstraints = false
        monetaryAmountLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [
            amountLabel,
            monetaryAmountLabel,
        ])
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        stackView.anchor(to: self, margin: 15)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
