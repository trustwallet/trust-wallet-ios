// Copyright SIX DAY LLC. All rights reserved.

import UIKit

class ProtectionCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    lazy var splashCoordinator: SplashCoordinator = {
        return SplashCoordinator(window: self.protectionWindow)
    }()
    lazy var lockEnterPasscodeCoordinator: LockEnterPasscodeCoordinator = {
        return LockEnterPasscodeCoordinator(window: self.protectionWindow, model: LockEnterPasscodeViewModel())
    }()
    let protectionWindow: UIWindow
    init() {
        self.protectionWindow = UIWindow()
    }
    func applicationWillResignActive() {
        //Show splash screen to protect sensetive information.
        splashCoordinator.start()
    }
    func applicationDidBecomeActive() {
        //Hide splash screen.
        splashCoordinator.dismiss()
        //Show passcode screen after app become active.
        if Lock().isPasscodeSet() {
            lockEnterPasscodeCoordinator.start()
        }
    }
}
