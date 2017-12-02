// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class CheckDeviceCoordinator: Coordinator {
    var coordinators: [Coordinator] = []

    let navigationController: UINavigationController

    lazy var alertViewController: UIAlertController = {
        let controller = UIAlertController(
            title: "DEVICE SECURITY COMPROMISED",
            message: "Any 'jailbreak' app can access Trust's keychain data and steal your bitcoin! Wipe this wallet immediately and restore on a secure device",
            preferredStyle: UIAlertControllerStyle.alert
        )

        controller.addAction(UIAlertAction(title: "Got it", style: UIAlertActionStyle.default))

        return controller
    }()

    init(
        navigationController: UINavigationController = NavigationController()
    ) {
        self.navigationController = navigationController
    }

    func start() {
        if isJailbroken() {
            navigationController.present(alertViewController, animated: true, completion: {
                // TODO what is next step?
                return
            })
        }
    }

    func isJailbroken() -> Bool {
        if TARGET_IPHONE_SIMULATOR == 1 {
            return false
        }

        return FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
            || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
            || FileManager.default.fileExists(atPath: "/bin/bash")
            || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
            || FileManager.default.fileExists(atPath: "/etc/apt")
            || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
    }
}
