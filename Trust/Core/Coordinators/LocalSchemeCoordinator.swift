// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore

protocol LocalSchemeCoordinatorDelegate: class {
    func didCancel(in coordinator: LocalSchemeCoordinator)
}

class LocalSchemeCoordinator: Coordinator {

    let navigationController: NavigationController
    let keystore: Keystore
    let session: WalletSession

    var coordinators: [Coordinator] = []
    weak var delegate: LocalSchemeCoordinatorDelegate?

    init(
        navigationController: NavigationController = NavigationController(),
        keystore: Keystore,
        session: WalletSession
    ) {
        self.navigationController = navigationController
        self.keystore = keystore
        self.session = session
    }

    func start() {
        switch session.account.type {
        case .privateKey(let account), .hd(let account) :
            signMessage(for: account)
        case .address:
            break
        }
    }

    func signMessage(for account: Account) {
        let coordinator = SignMessageCoordinator(
            navigationController: navigationController,
            keystore: keystore,
            account: account
        )
        coordinator.didComplete = { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let data):
                // analytics event for succesfully signed message
                // can we track by type without separate events for each case above?
                Analytics.track(.signedMessageFromBrowser)
            case .failure:
                //self.rootViewController.browserViewController.notifyFinish(callbackID: callbackID, value: .failure(DAppError.cancelled))

                // analytics event for failed message signing
                Analytics.track(.failedSignedMessageFromBrowser)

            }
            // do callback
            UIApplication.shared.open(URL(string: "trustexample://")!, options: [:]) { res in
                NSLog("res \(res)")
            }
            self.removeCoordinator(coordinator)
        }
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start(with: .message("test local scheme".data(using: String.Encoding.utf8)!))
    }
}

extension LocalSchemeCoordinator: SignMessageCoordinatorDelegate {
    func didCancel(in coordinator: SignMessageCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }
}
