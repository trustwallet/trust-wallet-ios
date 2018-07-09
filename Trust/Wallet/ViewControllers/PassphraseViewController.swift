// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

protocol PassphraseViewControllerDelegate: class {
    func didPressVerify(in controller: PassphraseViewController, with account: Account, words: [String])
}

enum PassphraseMode {
    case showOnly
    case showAndVerify
}

final class DarkPassphraseViewController: PassphraseViewController {

}

class PassphraseViewController: UIViewController {

    let viewModel = PassphraseViewModel()
    let account: Account
    let words: [String]
    lazy var actionButton: UIButton = {
        let button = Button(size: .large, style: .solid)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(R.string.localizable.next(), for: .normal)
        return button
    }()
    let subTitleLabel: SubtitleBackupLabel = {
        let label = SubtitleBackupLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString(
            "passphrase.seed.label.title",
            value: "These 12 words are the only way to restore your Trust wallet. \nSave them somewhere safe and secret.",
            comment: ""
        )
        return label
    }()
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

        view.backgroundColor = viewModel.backgroundColor

        setupViews(for: mode)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }

    func setupViews(for mode: PassphraseMode) {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = viewModel.title
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        titleLabel.textAlignment = .center

        copyButton.translatesAutoresizingMaskIntoConstraints = false
        copyButton.setTitle(NSLocalizedString("Copy", value: "Copy", comment: ""), for: .normal)
        copyButton.translatesAutoresizingMaskIntoConstraints = false

        let wordsLabel = UILabel()
        wordsLabel.translatesAutoresizingMaskIntoConstraints = false
        wordsLabel.numberOfLines = 0
        wordsLabel.text = words.joined(separator: "  ")
        wordsLabel.backgroundColor = .clear
        wordsLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        wordsLabel.textColor = Colors.black
        wordsLabel.textAlignment = .center
        wordsLabel.numberOfLines = 3
        wordsLabel.isUserInteractionEnabled = true
        wordsLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyGesture)))

        let wordBackgroundView = PassphraseBackgroundShadow()
        wordBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        wordBackgroundView.isUserInteractionEnabled = true

        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.image = R.image.write_passphrase()

        let stackView = UIStackView(arrangedSubviews: [
            image,
            titleLabel,
            .spacer(),
            subTitleLabel,
            .spacer(height: 15),
            wordsLabel,
            .spacer(),
            copyButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.backgroundColor = .clear

        view.addSubview(wordBackgroundView)
        view.addSubview(stackView)
        view.addSubview(actionButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.topAnchor, constant: StyleLayout.sideMargin),
            stackView.centerYAnchor.constraint(equalTo: view.readableContentGuide.centerYAnchor, constant: -40),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),

            actionButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            actionButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor, constant: -StyleLayout.sideMargin),

            wordBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wordBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wordBackgroundView.topAnchor.constraint(equalTo: wordsLabel.topAnchor, constant: -StyleLayout.sideMargin),
            wordBackgroundView.bottomAnchor.constraint(equalTo: wordsLabel.bottomAnchor, constant: StyleLayout.sideMargin),

            image.heightAnchor.constraint(equalToConstant: 32),

            stackView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),
        ])

        copyButton.addTarget(self, action: #selector(copyAction(_:)), for: .touchUpInside)

        switch mode {
        case .showOnly:
            actionButton.isHidden = true
        case .showAndVerify:
            actionButton.isHidden = false
        }
        actionButton.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)
    }

    func presentShare(in sender: UIView) {
        let copyValue = words.joined(separator: " ")
        showShareActivity(from: sender, with: [copyValue])
    }

    @objc private func copyAction(_ sender: UIButton) {
        presentShare(in: sender)
    }

    @objc private func copyGesture(_ sender: UIGestureRecognizer) {
        presentShare(in: sender.view!)
    }

    @objc private func nextAction(_ sender: UIButton) {
        delegate?.didPressVerify(in: self, with: account, words: words)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
