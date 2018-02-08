// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ProtectionCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    lazy var splashCoordinator: SplashCoordinator = {
        return SplashCoordinator(window: self.protectionWindow)
    }()
    lazy var lockEnterPasscodeCoordinator: LockEnterPasscodeCoordinator = {
        return LockEnterPasscodeCoordinator(model: LockEnterPasscodeViewModel())
    }()
    let protectionWindow = UIWindow()
    init() {
        protectionWindow.windowLevel = UIWindowLevelStatusBar + 2.0
    }

    func didFinishLaunchingWithOptions() {
        splashCoordinator.start()
        lockEnterPasscodeCoordinator.start()
    }

    func applicationWillResignActive() {
        splashCoordinator.start()
    }

    func applicationDidBecomeActive() {
        //We track protectionWasShown because of the Touch ID that will trigger applicationDidBecomeActive method after valdiation.
        if !lockEnterPasscodeCoordinator.protectionWasShown {
            lockEnterPasscodeCoordinator.start()
        } else {
            lockEnterPasscodeCoordinator.protectionWasShown = false
        }

        //We should dismiss spalsh screen when app become active.
        splashCoordinator.stop()
    }

    func applicationDidEnterBackground() {
        splashCoordinator.start()
    }

    func applicationWillEnterForeground() {
        splashCoordinator.stop()
    }
}
