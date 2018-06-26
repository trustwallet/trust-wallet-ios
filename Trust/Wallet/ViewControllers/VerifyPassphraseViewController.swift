// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

protocol VerifyPassphraseViewControllerDelegate: class {
    func didFinish(in controller: VerifyPassphraseViewController, with account: Account)
}

enum VerifyStatus {
    case empty
    case progress
    case invalid
    case correct

    var text: String {
        switch self {
        case .empty, .progress: return ""
        case .invalid: return NSLocalizedString("Invalid order ❌", value: "Invalid order ❌", comment: "")
        case .correct: return NSLocalizedString("Good job! Verified ✅", value: "Good job! Verified ✅", comment: "")
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

class VerifyPassphraseViewController: UIViewController {

    let contentView = PassphraseView()
    let proposalView = PassphraseView()
    let account: Account
    let words: [String]
    let shuffledWords: [String]
    weak var delegate: VerifyPassphraseViewControllerDelegate?

    lazy var doneButton: UIButton = {
        let button = Button(size: .large, style: .solid)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("Done", value: "Done", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(doneAction(_:)), for: .touchUpInside)
        return button
    }()

    lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textColor = Colors.black
        label.font = AppStyle.paragraphSmall.font
        label.text = NSLocalizedString("verifyPassphrase.label.title", value: "Tap the words to put them next to each other in the correct order.", comment: "")
        return label
    }()

    lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()

    private struct Layout {
        static let contentSize: CGFloat = 140
    }

    init(
        account: Account,
        words: [String]
    ) {
        self.account = account
        self.words = words
        self.shuffledWords = words.shuffled()

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = NSLocalizedString("Verify Recovery Phrase", value: "Verify Recovery Phrase", comment: "")
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

        let stackView = UIStackView(arrangedSubviews: [
            label,
            contentView,
            proposalView,
            statusLabel,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.backgroundColor = .clear

        let wordBackgroundView = UIView()
        wordBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        wordBackgroundView.backgroundColor = Colors.veryVeryLightGray
        view.addSubview(wordBackgroundView)

        view.addSubview(stackView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor, constant: StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: doneButton.bottomAnchor),

            wordBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            wordBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            wordBackgroundView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            wordBackgroundView.heightAnchor.constraint(equalToConstant: Layout.contentSize),

            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.contentSize),
            proposalView.heightAnchor.constraint(greaterThanOrEqualToConstant: Layout.contentSize),

            doneButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor),
            doneButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor, constant: -StyleLayout.sideMargin),
        ])

        refresh()
    }

    func refresh() {
        let status = VerifyStatus.from(initialWords: words, progressWords: contentView.words)

        doneButton.isEnabled = status == .correct
        statusLabel.text = status.text
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
