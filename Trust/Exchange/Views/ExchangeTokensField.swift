// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ExchangeTokensField: UIView {

    let fromField = ExchangeTokenInputField()
    let toField = ExchangeTokenInputField()

    lazy var availableBalanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(self.availableBalance))
        )
        label.isUserInteractionEnabled = true
        return label
    }()

    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: R.image.arrow_down())
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    var didPress: ((SelectTokenDirection) -> Void)?
    var didPressAvailableBalance: (() -> Void)?
    var didChangeValue: ((SelectTokenDirection, Double) -> Void)?

    init() {

        super.init(frame: .zero)

        fromField.translatesAutoresizingMaskIntoConstraints = false
        toField.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [
            .spacer(height: 20),
            fromField,
            .spacer(height: 5),
            availableBalanceLabel,
            .spacer(height: 15),
            arrowImageView,
            .spacer(height: 15),
            toField,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 0
        stackView.axis = .vertical

        fromField.didPress = { [unowned self] in self.didPress?(.from) }
        fromField.didChangeValue = { [unowned self] value in self.didChangeValue?(.from, value) }

        toField.didPress = { [unowned self] in self.didPress?(.to) }
        toField.didChangeValue = { [unowned self] value in self.didChangeValue?(.to, value) }

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),

            arrowImageView.widthAnchor.constraint(equalToConstant: 16),
        ])
    }

    @objc func availableBalance() {
        didPressAvailableBalance?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
