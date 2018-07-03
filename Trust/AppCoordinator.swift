// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import TrustCore
import UIKit
import URLNavigator

class AppCoordinator: NSObject, Coordinator {
    let navigationController: NavigationController
    lazy var welcomeViewController: WelcomeViewController = {
        let controller = WelcomeViewController()
        controller.delegate = self
        return controller
    }()
    let pushNotificationRegistrar = PushNotificationsRegistrar()
    private let lock = Lock()
    private var keystore: Keystore
    private var appTracker = AppTracker()
    private var navigator: URLNavigatorCoordinator

    var inCoordinator: InCoordinator? {
        return self.coordinators.compactMap { $0 as? InCoordinator }.first
    }

    var coordinators: [Coordinator] = []
    init(
        window: UIWindow,
        keystore: Keystore,
        navigator: URLNavigatorCoordinator = URLNavigatorCoordinator(),
        navigationController: NavigationController = NavigationController()
    ) {
        self.navigationController = navigationController
        self.keystore = keystore
        self.navigator = navigator
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
            let wallet = keystore.recentlyUsedWallet ?? keystore.wallets.first!
            let walletInfo = WalletInfo(wallet: wallet)
            showTransactions(for: walletInfo)
        } else {
            resetToWelcomeScreen()
        }
        pushNotificationRegistrar.reRegister()

        navigator.branch.newEventClosure = { [weak self] event in
            guard let coordinator = self?.inCoordinator else { return false }
            return coordinator.handleEvent(event)
        }
    }

    func showTransactions(for wallet: WalletInfo) {
        let coordinator = InCoordinator(
            navigationController: navigationController,
            wallet: wallet,
            keystore: keystore,
            appTracker: appTracker,
            navigator: navigator.navigator
        )
        coordinator.delegate = self
        coordinator.start()
        addCoordinator(coordinator)

        // Activate last event on first sign in
        guard let event = navigator.branch.lastEvent else { return }
        coordinator.handleEvent(event)
        navigator.branch.clearEvents()
    }

    func inializers() {
        var paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .allDomainsMask, true).compactMap { URL(fileURLWithPath: $0) }
        paths.append(keystore.keysDirectory)

        let initializers: [Initializer] = [
            CrashReportInitializer(),
            SkipBackupFilesInitializer(paths: paths),
        ]
        initializers.forEach { $0.perform() }
        //We should clean passcode if there is no wallets. This step is required for app reinstall.
        if !keystore.hasWallets {
           lock.clear()
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
        CookiesStore.delete()
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

    func didAddAccount(_ account: WalletInfo, in coordinator: InitialWalletCreationCoordinator) {
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
