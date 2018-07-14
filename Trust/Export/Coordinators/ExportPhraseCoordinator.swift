// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import TrustKeystore
import TrustCore

final class ExportPhraseCoordinator: RootCoordinator {

    let keystore: Keystore
    let account: Wallet
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
        account: Wallet,
        words: [String]
    ) {
        self.keystore = keystore
        self.account = account
        self.words = words
    }
}

extension ExportPhraseCoordinator: PassphraseViewControllerDelegate {
    func didPressVerify(in controller: PassphraseViewController, with account: Wallet, words: [String]) {
        // Missing functionality
    }
}
