// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class CheckDeviceCoordinator: Coordinator {
    var coordinators: [Coordinator] = []

    let navigationController: UINavigationController

    let jailbrakeChecker: JailbreakeChecker

    lazy var alertViewController: UIAlertController = {
        let controller = UIAlertController(
            title: NSLocalizedString("jailbrake.title", value: "DEVICE SECURITY COMPROMISED", comment: ""),
            message: NSLocalizedString(
                "jailbrake.message",
                value: "Any 'jailbreak' app can access Trust's keychain data and steal your bitcoin! Wipe this wallet immediately and restore on a secure device",
                comment: ""
            ),
            preferredStyle: UIAlertControllerStyle.alert
        )

        controller.addAction(UIAlertAction(title: NSLocalizedString("jailbrake.submit", value: "Got it", comment: ""), style: .default))

        return controller
    }()

    init(
        navigationController: UINavigationController,
        jailbrakeChecker: JailbreakeChecker
    ) {
        self.navigationController = navigationController
        self.jailbrakeChecker = jailbrakeChecker
    }

    func start() {
        if jailbrakeChecker.isJailbroken() {
            navigationController.present(alertViewController, animated: true, completion: nil)
        }
    }
}
