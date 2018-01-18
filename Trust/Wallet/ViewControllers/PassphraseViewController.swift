// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class PassphraseViewController: UIViewController {

    let passphraseView = PassphraseView(frame: .zero)
    let viewModel = PassphraseViewModel()

    init(words: [String]) {
        super.init(nibName: nil, bundle: nil)

        navigationItem.title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        passphraseView.translatesAutoresizingMaskIntoConstraints = false

        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = viewModel.rememberPassphraseText
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        let copyButton = Button(size: .small, style: .borderless)
        copyButton.setTitle(NSLocalizedString("Copy", value: "Copy", comment: ""), for: .normal)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.addTarget(self, action: #selector(copyAction), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            .spacer(height: 10),
            passphraseView,
            copyButton,
            label,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),
        ])

        passphraseView.words = words
    }

    @objc private func copyAction() {
        let copyValue = passphraseView.words.joined(separator: " ")
        UIPasteboard.general.string = copyValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
