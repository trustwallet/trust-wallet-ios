// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import TrustKeystore

protocol VerifyPassphraseViewControllerDelegate: class {
    func didFinish(in controller: VerifyPassphraseViewController, with account: Account)
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

    init(
        account: Account,
        words: [String]
    ) {
        self.account = account
        self.words = words
        self.shuffledWords = words.shuffled()

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = NSLocalizedString("Verify Phrase", value: "Verify Phrase", comment: "")
        view.backgroundColor = .white

        contentView.isEditable = true
        contentView.words = []
        contentView.didDeleteItem = { item in
            self.proposalView.words.append(item)
            self.refresh()
        }
        proposalView.isEditable = true
        proposalView.words = shuffledWords
        proposalView.didDeleteItem = { item in
            self.contentView.words.append(item)
            self.refresh()
        }

        let stackView = UIStackView(arrangedSubviews: [
            contentView,
            proposalView,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.backgroundColor = .clear

        view.addSubview(stackView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.readableContentGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: doneButton.bottomAnchor),

            doneButton.topAnchor.constraint(greaterThanOrEqualTo: stackView.bottomAnchor),
            doneButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor),
        ])

        refresh()
    }

    func refresh() {
        let isComplete = (words == contentView.words && words.count == contentView.words.count)
        self.doneButton.isEnabled = isComplete
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
