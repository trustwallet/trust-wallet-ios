// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

protocol PassphraseViewControllerDelegate: class {
    func didFinish(in controller: PassphraseViewController, with account: Account)
    func didPressVerify(in controller: PassphraseViewController, with account: Account, words: [String])
    func didPressShare(in controller: PassphraseViewController, sender: UIView, account: Account, words: [String])
}

enum PassphraseMode {
    case showOnly
    case showAndVerify
}

class PassphraseViewController: UIViewController {

    let passphraseView = PassphraseView()
    let viewModel = PassphraseViewModel()
    let account: Account
    weak var delegate: PassphraseViewControllerDelegate?

    init(
        account: Account,
        words: [String],
        mode: PassphraseMode = .showOnly
    ) {
        self.account = account

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
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setTitle(NSLocalizedString("Copy", value: "Copy", comment: ""), for: .normal)
        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setBackgroundColor(.clear, forState: .normal)
        copyButton.setBackgroundColor(.clear, forState: .highlighted)
        copyButton.addTarget(self, action: #selector(copyAction(_:)), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            .spacer(height: 10),
            passphraseView,
            copyButton,
            label,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10

        // if showAndVerify then add verify button

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor),

            passphraseView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
        ])

        passphraseView.words = words
    }

    @objc private func copyAction(_ sender: UIButton) {
        delegate?.didPressShare(in: self, sender: sender, account: account, words: passphraseView.words)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
