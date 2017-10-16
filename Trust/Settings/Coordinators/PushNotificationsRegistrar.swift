// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UserNotifications
import UIKit

class PushNotificationsRegistrar {

    let client = PushNotificationsClient()

    func register() {
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { _ in }
            UIApplication.shared.registerForRemoteNotifications()
        } else if #available(iOS 9, *) {
            UIApplication.shared.registerUserNotificationSettings(UIUserNotificationSettings(types: [.badge, .sound, .alert], categories: nil))
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

    func unregister() {
        let device = PushDevice(
            deviceID: UIDevice.current.identifierForVendor!.uuidString,
            token: "",
            wallets: []
        )

        client.unregister(device: device)
        UIApplication.shared.unregisterForRemoteNotifications()
    }

    func didRegister(with deviceToken: Data, addresses: [Address]) {
        let token = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }.joined()

        let device = PushDevice(
            deviceID: UIDevice.current.identifierForVendor!.uuidString,
            token: token,
            wallets: addresses.map { $0.address }
        )
        client.register(device: device)
    }
}
