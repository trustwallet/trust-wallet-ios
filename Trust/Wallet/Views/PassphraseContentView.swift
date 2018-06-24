// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class PassphraseContentView: UIView {

    let passphraseView = PassphraseView()
    let label = UILabel(frame: .zero)
    let copyButton = Button(size: .small, style: .clear)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear

        passphraseView.translatesAutoresizingMaskIntoConstraints = false

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = NSLocalizedString(
            "passphrase.remember.label.title",
            value: "Write this down, and keep it private and secure. You won't be able to restore your wallet if you lose this!",
            comment: ""
        )
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setTitle(NSLocalizedString("Copy", value: "Copy", comment: ""), for: .normal)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setBackgroundColor(.clear, forState: .normal)
        copyButton.setBackgroundColor(.clear, forState: .highlighted)

        let stackView = UIStackView(arrangedSubviews: [
            .spacer(height: 10),
            passphraseView,
            copyButton,
            label,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.backgroundColor = .clear

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),

            passphraseView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
