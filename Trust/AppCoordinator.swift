// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustKeystore
import UIKit

class AppCoordinator: NSObject, Coordinator {
    let navigationController: UINavigationController
    lazy var welcomeViewController: WelcomeViewController = {
        let controller = WelcomeViewController()
        controller.delegate = self
        return controller
    }()
    let pushNotificationRegistrar = PushNotificationsRegistrar()
    private let lock = Lock()
    private var keystore: Keystore
    private var appTracker = AppTracker()
    var coordinators: [Coordinator] = []
    init(
        window: UIWindow,
        keystore: Keystore,
        navigationController: UINavigationController = NavigationController()
    ) {
        self.navigationController = navigationController
        self.keystore = keystore
        super.init()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func start() {
        inializers()
        appTracker.start()
        handleNotifications()
        applyStyle()
        resetToWelcomeScreen()

        if keystore.hasWallets {
            showTransactions(for: keystore.recentlyUsedWallet ?? keystore.wallets.first!)
        } else {
            resetToWelcomeScreen()
        }
        pushNotificationRegistrar.reRegister()
    }

    func showTransactions(for wallet: Wallet) {
        let coordinator = InCoordinator(
            navigationController: navigationController,
            wallet: wallet,
            keystore: keystore,
            appTracker: appTracker
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }

    func inializers() {
        let initializers: [Initializer] = [
            CrashReportInitializer(),
            LokaliseInitializer(),
            SkipBackupFilesInitializer(),
        ]
        initializers.forEach { $0.perform() }
        //We should clean passcode if there is no wallets. This step is required for app reinstall.
        if !keystore.hasWallets {
           lock.deletePasscode()
        }
    }

    func handleNotifications() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func resetToWelcomeScreen() {
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.viewControllers = [welcomeViewController]
    }

    @objc func reset() {
        lock.deletePasscode()
        pushNotificationRegistrar.unregister()
        coordinators.removeAll()
        navigationController.dismiss(animated: true, completion: nil)
        resetToWelcomeScreen()
    }

    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        pushNotificationRegistrar.didRegister(
            with: deviceToken,
            addresses: keystore.wallets.map { $0.address }
        )
    }

    func showInitialWalletCoordinator(entryPoint: WalletEntryPoint) {
        let coordinator = InitialWalletCreationCoordinator(
            navigationController: navigationController,
            keystore: keystore,
            entryPoint: entryPoint
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)
    }
}

extension AppCoordinator: WelcomeViewControllerDelegate {
    func didPressCreateWallet(in viewController: WelcomeViewController) {
        showInitialWalletCoordinator(entryPoint: .createInstantWallet)
    }

    func didPressImportWallet(in viewController: WelcomeViewController) {
        showInitialWalletCoordinator(entryPoint: .importWallet)
    }
}

extension AppCoordinator: InitialWalletCreationCoordinatorDelegate {
    func didCancel(in coordinator: InitialWalletCreationCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }

    func didAddAccount(_ account: Wallet, in coordinator: InitialWalletCreationCoordinator) {
        coordinator.navigationController.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
        showTransactions(for: account)
    }
}

extension AppCoordinator: InCoordinatorDelegate {
    func didCancel(in coordinator: InCoordinator) {
        removeCoordinator(coordinator)
        pushNotificationRegistrar.reRegister()
        reset()
    }

    func didUpdateAccounts(in coordinator: InCoordinator) {
        pushNotificationRegistrar.reRegister()
    }
}
