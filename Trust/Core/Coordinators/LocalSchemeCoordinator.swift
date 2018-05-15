// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore
import TrustKeystore
import TrustSDK

protocol LocalSchemeCoordinatorDelegate: class {
    func didCancel(in coordinator: LocalSchemeCoordinator)
}

class LocalSchemeCoordinator: Coordinator {

    let navigationController: NavigationController
    let keystore: Keystore
    let session: WalletSession
    let url: URL
    var coordinators: [Coordinator] = []
    weak var delegate: LocalSchemeCoordinatorDelegate?

    init(
        navigationController: NavigationController = NavigationController(),
        keystore: Keystore,
        session: WalletSession,
        url: URL
    ) {
        self.navigationController = navigationController
        self.keystore = keystore
        self.session = session
        self.url = url
    }

    func start() {
        parse(url: url as! URL)
    }

    func parse(url: URL) {
        let component = URLComponents(url: url, resolvingAgainstBaseURL: true)
        switch component?.host {
        case "sign-message":
            let messageBase64 = component?.queryItems?.filter { $0.name == "message" }.first!.value
            let callbackBase64 = component?.queryItems?.filter { $0.name == "callback" }.first!.value
            let message = messageBase64!.base64Decoded!
            let callback: String = callbackBase64!

            switch session.account.type {
            case .privateKey(let account), .hd(let account):
                let command = SignMessageCommand(
                    message: message,
                    callbackScheme: "trustexample",
                    completion: { data in }
                )
                signMessage(for: account, command: command)
            case .address:
                break
            }
        default: break
        }
    }

    func signMessage(for account: Account, command: SignMessageCommand) {
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
                //Analytics.track(.signedMessageFromBrowser)

                NSLog("data \(data)")
                NSLog("command \(command)")

                let res = command.callback
                NSLog("res \(res)")
                UIApplication.shared.open(res, options: [:]) { res in
                    NSLog("res \(res)")
                }
            case .failure:
                break
                //self.rootViewController.browserViewController.notifyFinish(callbackID: callbackID, value: .failure(DAppError.cancelled))

                // analytics event for failed message signing
                //Analytics.track(.failedSignedMessageFromBrowser)
            }
            self.removeCoordinator(coordinator)
        }
        coordinator.delegate = self
        addCoordinator(coordinator)
        coordinator.start(with: .message(command.message))
    }
}

extension LocalSchemeCoordinator: SignMessageCoordinatorDelegate {
    func didCancel(in coordinator: SignMessageCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
    }
}
