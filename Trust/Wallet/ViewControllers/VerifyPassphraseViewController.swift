// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

protocol VerifyPassphraseViewControllerDelegate: class {
    func didFinish(in controller: VerifyPassphraseViewController, with account: Wallet)
    func didSkip(in controller: VerifyPassphraseViewController, with account: Wallet)
}

enum VerifyStatus {
    case empty
    case progress
    case invalid
    case correct

    var text: String {
        switch self {
        case .empty, .progress: return ""
        case .invalid: return NSLocalizedString("verify.passphrase.invalidOrder.title", value: "Invalid order. Try again!", comment: "")
        case .correct:
            return String(format: NSLocalizedString("verify.passphrase.welldone.title", value: "Well done! %@", comment: ""), "✅")
        }
    }

    var textColor: UIColor {
        switch self {
        case .empty, .progress, .correct: return Colors.black
        case .invalid: return Colors.red
        }
    }

    static func from(initialWords: [String], progressWords: [String]) -> VerifyStatus {
        guard !progressWords.isEmpty else { return .empty }

        if initialWords == progressWords && initialWords.count == progressWords.count {
            return .correct
        }

        if progressWords == Array(initialWords.prefix(progressWords.count)) {
            return .progress
        }

        return .invalid
    }
}

class DarkVerifyPassphraseViewController: VerifyPassphraseViewController {

}

class SubtitleBackupLabel: UILabel {

    init() {
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        textAlignment = .center
        numberOfLines = 0
        font = AppStyle.paragraph.font
        textColor = Colors.gray
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class VerifyPassphraseViewController: UIViewController {

    let contentView = PassphraseView()
    let proposalView = PassphraseView()
    let account: Wallet
    let words: [String]
    let shuffledWords: [String]
    weak var delegate: VerifyPassphraseViewControllerDelegate?

    lazy var doneButton: UIButton = {
        let button = Button(size: .large, style: .solid)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(R.string.localizable.done(), for: .normal)
        button.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
        return button
    }()

    lazy var subTitleLabel: SubtitleBackupLabel = {
        let label = SubtitleBackupLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = NSLocalizedString("verifyPassphrase.label.title", value: "Tap the words to put them next to each other in the correct order.", comment: "")
        return label
    }()

    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = R.string.localizable.verifyBackupPhrase()
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    private struct Layout {
        static let contentSize: CGFloat = 140
    }

    init(
        account: Wallet,
        words: [String]
    ) {
        self.account = account
        self.words = words
        self.shuffledWords = words.shuffled()

        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: R.string.localizable.skip(), style: .plain, target: self, action: #selector(skipAction))

        view.backgroundColor = .white

        contentView.isEditable = true
        contentView.words = []
        contentView.didDeleteItem = { item in
            self.proposalView.words.append(item)
            self.refresh()
        }
        contentView.backgroundColor = .clear
        contentView.collectionView.backgroundColor = .clear

        proposalView.isEditable = true
        proposalView.words = shuffledWords
        proposalView.didDeleteItem = { item in
            self.contentView.words.append(item)
            self.refresh()
        }

        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        image.image = R.image.verify_passphrase()

        let stackView = UIStackView(arrangedSubviews: [
            image,
            titleLabel,
            .spacer(),
            subTitleLabel,
            .spacer(),
            contentView,
            proposalView,
            statusLabel,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.backgroundColor = .clear

        let wordBackgroundView = PassphraseBackgroundShadow()
        wordBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(wordBackgroundView)

        view.addSubview(stackView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.topAnchor, constant: StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.centerYAnchor, constant: -80),

            wordBackgroundView.topAnchor.constraint(equalTo: contentView.topAnchor),
            wordBackgroundView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            wordBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wordBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),
            proposalView.heightAnchor.constraint(greaterThanOrEqualToConstant: 48),

            image.heightAnchor.constraint(equalToConstant: 32),
            statusLabel.heightAnchor.constraint(equalToConstant: 34),

            doneButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor, constant: -StyleLayout.sideMargin),
        ])

        refresh()
    }

    @objc func skipAction() {
        // TODO: Add confirm warning
        delegate?.didSkip(in: self, with: account)
    }

    func refresh() {
        let progressWords = contentView.words
        let status = VerifyStatus.from(initialWords: words, progressWords: progressWords)

        doneButton.isEnabled = status == .correct
        statusLabel.text = status.text
        statusLabel.textColor = status.textColor
    }

    @objc private func doneAction(_ sender: UIButton) {
        delegate?.didFinish(in: self, with: account)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MutableCollection {
    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }
}

extension Sequence {
    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }
}
