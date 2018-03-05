// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class TokensHeaderView: UIView {

    lazy var amountLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = Colors.black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    lazy var sendButton: Button = {
        let sendButton = Button(size: .large, style: .squared)
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.layer.cornerRadius = 6
        sendButton.setTitle(NSLocalizedString("Send", value: "Send", comment: ""), for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
        return sendButton
    }()

    lazy var requestButton: Button = {
        let requestButton = Button(size: .large, style: .squared)
        requestButton.translatesAutoresizingMaskIntoConstraints = false
        requestButton.layer.cornerRadius = 6
        requestButton.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: UIFont.Weight.medium)
        requestButton.setTitle(NSLocalizedString("transactions.receive.button.title", value: "Receive", comment: ""), for: .normal)
        return requestButton
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        let buttonsStackView = UIStackView(arrangedSubviews: [
            sendButton,
            requestButton,
            ])
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.isLayoutMarginsRelativeArrangement = true
        buttonsStackView.layoutMargins = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
        buttonsStackView.distribution = .fillEqually
        buttonsStackView.spacing = 15

        let stackView = UIStackView(arrangedSubviews: [
            amountLabel,
            buttonsStackView,
        ])

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: StyleLayout.sideMargin + 10),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -StyleLayout.sideMargin - 10),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
