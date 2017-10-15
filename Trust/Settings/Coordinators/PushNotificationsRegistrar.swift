// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UserNotifications
import UIKit

class PushNotificationsRegistrar {

    func register() {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]) { _ in }
            UIApplication.shared.registerForRemoteNotifications()
        } else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func unregister() {
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    func didRegister(with deviceToken: Data, addresses: [Address]) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()

        print("Device Token: \(token)")
    }

    private func registerRemote() {

    }

    private func unregisterRemote() {

    }
}
