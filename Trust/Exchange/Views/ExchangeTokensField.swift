// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ExchangeTokensField: UIView {

    let to = ExchangeTokenInputField()
    let from = ExchangeTokenInputField()

    init() {

        super.init(frame: .zero)

        to.translatesAutoresizingMaskIntoConstraints = false
        from.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [
            to,
            from,
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
