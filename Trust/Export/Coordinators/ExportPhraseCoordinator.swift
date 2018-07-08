// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore
import TrustCore

class ExportPhraseCoordinator: RootCoordinator {

    let keystore: Keystore
    let account: Account
    let words: [String]
    var coordinators: [Coordinator] = []
    var rootViewController: UIViewController {
        return passphraseViewController
    }
    var passphraseViewController: PassphraseViewController {
        let controller = PassphraseViewController(
            account: account,
            words: words
        )
        controller.delegate = self
        controller.title = viewModel.title
        return controller
    }
    private lazy var viewModel: ExportPhraseViewModel = {
        return .init(keystore: keystore, account: account)
    }()

    init(
        keystore: Keystore,
        account: Account,
        words: [String]
    ) {
        self.keystore = keystore
        self.account = account
        self.words = words
    }
}

extension ExportPhraseCoordinator: PassphraseViewControllerDelegate {
    func didFinish(in controller: PassphraseViewController, with account: Account) {
        //delegate?.didCancel(in: self)
    }

    func didPressVerify(in controller: PassphraseViewController, with account: Account, words: [String]) {
        // Missing functionality
    }

    func didPressShare(in controller: PassphraseViewController, sender: UIView, account: Account, words: [String]) {
        let copyValue = words.joined(separator: " ")
        rootViewController.showShareActivity(from: sender, with: [copyValue])
    }
}
