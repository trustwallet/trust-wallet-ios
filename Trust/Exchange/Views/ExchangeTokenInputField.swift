// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ExchangeTokenInputField: UIView {

    let valueInput  = ExchangeValueInput()
    let tokenView = ExchangeTokenView()

    init() {

        super.init(frame: .zero)

        valueInput.translatesAutoresizingMaskIntoConstraints = false

        tokenView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [
            valueInput,
            tokenView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 120),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
