// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class CheckDeviceCoordinator: Coordinator {
    var coordinators: [Coordinator] = []

    let navigationController: NavigationController

    let jailbreakChecker: JailbreakChecker

    lazy var rootViewController: UIAlertController = {
        let controller = UIAlertController(
            title: NSLocalizedString("app.device.jailbreak.title", value: "DEVICE SECURITY COMPROMISED", comment: ""),
            message: NSLocalizedString(
                "app.device.jailbreak.description",
                value: "Any 'jailbreak' app can access Trust's keychain data and steal your wallet! Wipe this wallet immediately and restore on a secure device.",
                comment: ""
            ),
            preferredStyle: UIAlertControllerStyle.alert
        )
        controller.popoverPresentationController?.sourceView = navigationController.view
        controller.addAction(UIAlertAction(title: R.string.localizable.oK(), style: .default))
        return controller
    }()

    init(
        navigationController: NavigationController,
        jailbreakChecker: JailbreakChecker
    ) {
        self.navigationController = navigationController
        self.jailbreakChecker = jailbreakChecker
    }

    func start() {
        if jailbreakChecker.isJailbroken() {
            navigationController.present(rootViewController, animated: true, completion: nil)
        }
    }
}
