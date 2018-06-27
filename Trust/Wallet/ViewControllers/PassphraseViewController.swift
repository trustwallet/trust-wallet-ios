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

    let viewModel = PassphraseViewModel()
    let account: Account
    let words: [String]
    lazy var button: UIButton = {
        let button = Button(size: .large, style: .solid)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Verify", value: "Verify", comment: ""), for: .normal)
        return button
    }()
    let subTitleLabel = UILabel()
    let copyButton = Button(size: .extraLarge, style: .clear)
    weak var delegate: PassphraseViewControllerDelegate?

    init(
        account: Account,
        words: [String],
        mode: PassphraseMode = .showOnly
    ) {
        self.account = account
        self.words = words

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        setupViews(for: mode)
    }

    func setupViews(for mode: PassphraseMode) {
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.textAlignment = .center
        subTitleLabel.numberOfLines = 0
        subTitleLabel.text = NSLocalizedString(
            "passphrase.seed.label.title",
            value: "These 12 words are the only way to restore your Trust accounts. Save them somewhere safe and secret.",
            comment: ""
        )
        subTitleLabel.font = AppStyle.heading.font
        subTitleLabel.textColor = AppStyle.heading.textColor

        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setTitle(NSLocalizedString("Copy", value: "Copy", comment: ""), for: .normal)
        copyButton.translatesAutoresizingMaskIntoConstraints = false

        let wordsLabel = UILabel()
        wordsLabel.translatesAutoresizingMaskIntoConstraints = false
        wordsLabel.numberOfLines = 0
        wordsLabel.text = words.joined(separator: ", ")
        wordsLabel.backgroundColor = .clear
        wordsLabel.font = UIFont.systemFont(ofSize: 22, weight: .regular)
        wordsLabel.textColor = Colors.black
        wordsLabel.textAlignment = .center

        let wordBackgroundView = UIView()
        wordBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        wordBackgroundView.backgroundColor = Colors.veryVeryLightGray

        let stackView = UIStackView(arrangedSubviews: [
            .spacer(height: 10),
            subTitleLabel,
            .spacer(height: 30),
            wordsLabel,
            .spacer(height: 30),
            copyButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.backgroundColor = .clear

        view.addSubview(wordBackgroundView)
        view.addSubview(stackView)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.topAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.readableContentGuide.centerYAnchor, constant: -80),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),

            button.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor, constant: -StyleLayout.sideMargin),

            wordBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wordBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wordBackgroundView.centerYAnchor.constraint(equalTo: wordsLabel.centerYAnchor),
            wordBackgroundView.heightAnchor.constraint(equalToConstant: 110),

            stackView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
        ])

        copyButton.addTarget(self, action: #selector(copyAction(_:)), for: .touchUpInside)

        switch mode {
        case .showOnly:
            button.isHidden = true
        case .showAndVerify:
            button.isHidden = false
        }
        button.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
    }

    @objc private func copyAction(_ sender: UIButton) {
        delegate?.didPressShare(in: self, sender: sender, account: account, words: words)
    }

    @objc private func nextAction(_ sender: UIButton) {
        delegate?.didPressVerify(in: self, with: account, words: words)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
