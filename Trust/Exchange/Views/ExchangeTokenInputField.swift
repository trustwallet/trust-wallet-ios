// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ExchangeTokenInputField: UIView {

    let floatLabelView = UIView()
    let destinationLabel = UILabel()
    let amountField = UITextField()

    let tokenView = UIView()
    let tokenImageView = UIImageView()
    let symbolLabel = UILabel()

    var didPress: (() -> Void)?

    init() {

        super.init(frame: .zero)

        // value

        floatLabelView.translatesAutoresizingMaskIntoConstraints = false

        destinationLabel.translatesAutoresizingMaskIntoConstraints = false

        amountField.translatesAutoresizingMaskIntoConstraints = false
        amountField.backgroundColor = .red
        amountField.font = UIFont.systemFont(ofSize: 26, weight: UIFontWeightMedium)

        let inputStackView = UIStackView(arrangedSubviews: [
            destinationLabel,
            amountField,
        ])
        inputStackView.translatesAutoresizingMaskIntoConstraints = false
        inputStackView.axis = .vertical
        inputStackView.spacing = 5

        addSubview(floatLabelView)
        floatLabelView.addSubview(inputStackView)

        NSLayoutConstraint.activate([
            inputStackView.centerYAnchor.constraint(equalTo: floatLabelView.centerYAnchor),
            inputStackView.leadingAnchor.constraint(equalTo: floatLabelView.leadingAnchor),
            inputStackView.trailingAnchor.constraint(equalTo: floatLabelView.trailingAnchor, constant: -15),

            floatLabelView.topAnchor.constraint(equalTo: topAnchor),
            floatLabelView.leadingAnchor.constraint(equalTo: leadingAnchor),
            floatLabelView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        // token view

        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.textAlignment = .center
        symbolLabel.text = "ETH"

        tokenImageView.translatesAutoresizingMaskIntoConstraints = false
        tokenImageView.image = R.image.accounts_active()

        tokenView.translatesAutoresizingMaskIntoConstraints = false
        tokenView.backgroundColor = .green

        let tokenStackView = UIStackView(arrangedSubviews: [
            tokenImageView,
            symbolLabel,
        ])
        tokenStackView.translatesAutoresizingMaskIntoConstraints = false
        tokenStackView.axis = .vertical
        tokenStackView.spacing = 5

        tokenView.addSubview(tokenStackView)
        addSubview(tokenView)

        let chevronDownImageView = UIImageView(image: R.image.chevronDown())
        chevronDownImageView.translatesAutoresizingMaskIntoConstraints = false

        tokenView.addSubview(chevronDownImageView)

        NSLayoutConstraint.activate([
            tokenStackView.centerXAnchor.constraint(equalTo: tokenView.centerXAnchor),
            tokenStackView.centerYAnchor.constraint(equalTo: tokenView.centerYAnchor),

            tokenView.topAnchor.constraint(equalTo: topAnchor),
            tokenView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tokenView.bottomAnchor.constraint(equalTo: bottomAnchor),
            tokenView.widthAnchor.constraint(equalToConstant: 100),
            tokenView.leadingAnchor.constraint(equalTo: floatLabelView.trailingAnchor),

            chevronDownImageView.leadingAnchor.constraint(equalTo: tokenStackView.trailingAnchor),
            chevronDownImageView.centerYAnchor.constraint(equalTo: tokenStackView.centerYAnchor),
        ])

        // main stack

        let stackView = UIStackView(arrangedSubviews: [
            floatLabelView,
            tokenView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.tap))
        )

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 100),
        ])
    }

    func tap() {
        didPress?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
