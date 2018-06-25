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

    let contentView = PassphraseContentView()
    let viewModel = PassphraseViewModel()
    let account: Account
    let words: [String]
    lazy var button: UIButton = {
        let button = Button(size: .large, style: .solid)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Verify", value: "Verify", comment: ""), for: .normal)
        return button
    }()
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

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.copyButton.addTarget(self, action: #selector(copyAction(_:)), for: .touchUpInside)
        contentView.passphraseView.words = words
        view.addSubview(contentView)
        view.addSubview(button)

        switch mode {
        case .showOnly:
            button.isHidden = true
        case .showAndVerify:
            button.isHidden = false
        }
        button.addTarget(self, action: #selector(nextAction(_:)), for: .touchUpInside)

        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            contentView.bottomAnchor.constraint(lessThanOrEqualTo: button.topAnchor),

            button.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            button.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor, constant: -StyleLayout.sideMargin),
        ])
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
