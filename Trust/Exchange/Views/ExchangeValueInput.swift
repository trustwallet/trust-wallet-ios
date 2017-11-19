// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class ExchangeValueInput: UIView {
    let label = UITextField()
    let amountField = UITextField()

    init() {

        super.init(frame: .zero)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "From"

        amountField.translatesAutoresizingMaskIntoConstraints = false
        amountField.backgroundColor = .red

        let stackView = UIStackView(arrangedSubviews: [
            label,
            amountField,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
