// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ExchangeTokenInputField: UIView {

    let amountField = UITextField()
    let tokenImageView = UIImageView()
    let symbolLabel = UILabel()
    let chevronDownImageView = UIImageView(image: R.image.chevronRight())

    var didPress: (() -> Void)?
    var didChangeValue: ((Double) -> Void)?

    init() {

        super.init(frame: .zero)

        amountField.translatesAutoresizingMaskIntoConstraints = false
        amountField.placeholder = "0"
        amountField.font = UIFont.systemFont(ofSize: 22, weight: UIFontWeightMedium)
        amountField.addTarget(self, action: #selector(amountDidChange(_:)), for: .editingChanged)
        amountField.keyboardType = .decimalPad

        symbolLabel.translatesAutoresizingMaskIntoConstraints = false
        symbolLabel.textAlignment = .center
        symbolLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFontWeightMedium)
        symbolLabel.adjustsFontSizeToFitWidth = true

        tokenImageView.translatesAutoresizingMaskIntoConstraints = false
        tokenImageView.image = R.image.accounts_active()
        tokenImageView.contentMode = .scaleAspectFit

        chevronDownImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronDownImageView.contentMode = .scaleAspectFit
        chevronDownImageView.alpha = 0.5

        let divider: UIView = .spacerWidth(0.5, backgroundColor: .lightGray, alpha: 0.5)

        let tokenStackView = UIStackView(arrangedSubviews: [
            tokenImageView,
            symbolLabel,
            chevronDownImageView,
        ])
        tokenStackView.translatesAutoresizingMaskIntoConstraints = false
        tokenStackView.axis = .horizontal
        tokenStackView.spacing = 5

        let stackView = UIStackView(arrangedSubviews: [
            amountField,
            divider,
            .spacerWidth(),
            tokenStackView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 5
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: StyleLayout.sideMargin),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -StyleLayout.sideMargin),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            stackView.heightAnchor.constraint(equalToConstant: 60),

            amountField.widthAnchor.constraint(equalToConstant: 150),

            symbolLabel.widthAnchor.constraint(equalToConstant: 50),

            divider.topAnchor.constraint(equalTo: topAnchor, constant: StyleLayout.sideMargin),
            divider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -StyleLayout.sideMargin),

            chevronDownImageView.widthAnchor.constraint(equalToConstant: 14),
        ])

        // main stack

        tokenStackView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.tap))
        )

        layer.cornerRadius = 5
        layer.masksToBounds = true
    }

    func tap() {
        didPress?()
    }

    func amountDidChange(_ textField: UITextField) {
        guard let value = textField.text?.doubleValue else {
            return
        }
        didChangeValue?(value)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
