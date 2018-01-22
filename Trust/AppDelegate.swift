// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Lokalise

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    var window: UIWindow?
    var coordinator: AppCoordinator!
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        do {
            let keystore = try EtherKeystore()
            coordinator = AppCoordinator(window: window!, keystore: keystore)
            coordinator.start()
        } catch {
            print("EtherKeystore init issue.")
        }
        return true
    }
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        coordinator.didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: deviceToken)
    }
    func applicationWillResignActive(_ application: UIApplication) {
        coordinator.applicationWillResignActive()
    }
    func applicationDidBecomeActive(_ application: UIApplication) {
        Lokalise.shared.checkForUpdates { _, _ in }
        coordinator.applicationDidBecomeActive()
    }
    func application(_ application: UIApplication, shouldAllowExtensionPointIdentifier extensionPointIdentifier: UIApplicationExtensionPointIdentifier) -> Bool {
        if extensionPointIdentifier == UIApplicationExtensionPointIdentifier.keyboard {
            return false
        }
        return true
    }
}
