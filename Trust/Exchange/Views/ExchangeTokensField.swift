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

    var didPress: ((SelectTokenDirection) -> Void)?
    var didPressAvailableBalance: (() -> Void)?

    init() {

        super.init(frame: .zero)

        fromField.translatesAutoresizingMaskIntoConstraints = false
        toField.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [
            destinationLabel(text: "FROM"),
            fromField,
            availableBalanceLabel,
            .spacer(height: 0),
            destinationLabel(text: "TO"),
            toField,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 10
        stackView.axis = .vertical

        fromField.didPress = { [unowned self] in self.didPress?(.from) }
        toField.didPress = { [unowned self] in self.didPress?(.to) }

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    private func destinationLabel(text: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = text
        return label
    }

    func availableBalance() {
        didPressAvailableBalance?()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
