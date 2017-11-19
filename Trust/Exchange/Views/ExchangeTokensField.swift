// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ExchangeTokensField: UIView {

    let to = ExchangeTokenInputField()
    let from = ExchangeTokenInputField()
    let swapButton = UIButton()

    init() {

        super.init(frame: .zero)

        to.translatesAutoresizingMaskIntoConstraints = false
        to.destinationLabel.text = "You send"

        from.translatesAutoresizingMaskIntoConstraints = false
        from.destinationLabel.text = "You get"

        swapButton.translatesAutoresizingMaskIntoConstraints = false
        swapButton.setImage(R.image.swap(), for: .normal)
        swapButton.addTarget(self, action: #selector(swap), for: .touchUpInside)
        swapButton.layer.cornerRadius = 20
        swapButton.backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [
            to,
            from,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        addSubview(stackView)
        addSubview(swapButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            swapButton.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            swapButton.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: -80),
            swapButton.widthAnchor.constraint(equalToConstant: 40),
            swapButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }

    func swap() {

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
