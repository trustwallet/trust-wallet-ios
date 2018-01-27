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
        if !lockEnterPasscodeCoordinator.passcodeViewIsActive {
            splashCoordinator.start()
        }
    }
    func applicationDidBecomeActive() {
        if !lockEnterPasscodeCoordinator.passcodeViewIsActive {
            splashCoordinator.dismiss()
        }
    }
    func didFinishLaunchingWithOptions() {
        lockEnterPasscodeCoordinator.start()
    }
}
