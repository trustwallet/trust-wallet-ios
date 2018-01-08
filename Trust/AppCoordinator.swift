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

    lazy var touchRegistrar: TouchRegistrar = {
        return TouchRegistrar(keystore: self.keystore)
    }()

    let pushNotificationRegistrar = PushNotificationsRegistrar()

    private var keystore: Keystore

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
        handleNotifications()
        applyStyle()
        resetToWelcomeScreen()

        if keystore.hasAccounts {
            showTransactions(for: keystore.recentlyUsedAccount ?? keystore.accounts.first!)
        } else {
            resetToWelcomeScreen()
        }
        pushNotificationRegistrar.reRegister()
    }

    func showTransactions(for account: Account) {

        let coordinator = InCoordinator(
            navigationController: navigationController,
            account: account,
            keystore: keystore
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

        touchRegistrar.register()
    }

    func handleNotifications() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func resetToWelcomeScreen() {
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.viewControllers = [welcomeViewController]
    }

    @objc func reset() {
        touchRegistrar.unregister()
        pushNotificationRegistrar.unregister()
        coordinators.removeAll()
        navigationController.dismiss(animated: true, completion: nil)
        resetToWelcomeScreen()
    }

    func didRegisterForRemoteNotificationsWithDeviceToken(deviceToken: Data) {
        pushNotificationRegistrar.didRegister(
            with: deviceToken,
            addresses: keystore.accounts.map { $0.address }
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

    func didAddAccount(_ account: Account, in coordinator: InitialWalletCreationCoordinator) {
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
