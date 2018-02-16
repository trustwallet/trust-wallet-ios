// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka

struct NotificationChange: Codable {
    let isEnabled: Bool
    let preferences: Preferences
}

enum NotificationChanged {
    case state(isEnabled: Bool)
    case preferences(Preferences)
}

class NotificationsViewController: FormViewController {

    private let viewModel = NotificationsViewModel()
    private let preferencesController: PreferencesController

    private struct Keys {
        static let pushNotifications = "pushNotifications"
        static let airdropNotifications = "airdropNotifications"
    }

    var didChange: ((_ change: NotificationChanged) -> Void)?

    private static var isPushNotificationEnabled: Bool {
        guard let settings = UIApplication.shared.currentUserNotificationSettings else { return false }
        return UIApplication.shared.isRegisteredForRemoteNotifications && !settings.types.isEmpty
    }

    init(
        preferencesController: PreferencesController = PreferencesController()
    ) {
        self.preferencesController = preferencesController
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title

        form +++ Section()

            <<< SwitchRow(Keys.pushNotifications) {
                $0.title = NSLocalizedString("settings.allowPushNotifications.button.title", value: "Allow Push Notifications", comment: "")
                $0.value = NotificationsViewController.isPushNotificationEnabled
            }.onChange { [unowned self] row in
                self.didChange?(.state(isEnabled: row.value ?? false))
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_push_notifications()
            }

        +++ Section()
            <<< SwitchRow(Keys.airdropNotifications) {
                $0.title = NSLocalizedString("settings.pushNotifications.airdrop.button.title", value: "Airdrops notifications", comment: "")
                $0.value = preferencesController.get(for: .airdropNotifications)
                $0.hidden = Condition.predicate(NSPredicate(format: "$\(Keys.pushNotifications) == false"))
            }.onChange { [unowned self] row in
                self.preferencesController.set(value: row.value ?? false, for: .airdropNotifications)
                self.updatePreferences()
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_airdrop()
            }
    }

    func updatePreferences() {
        didChange?(.preferences(
            NotificationsViewController.getPreferences()
        ))
    }

    static func getPreferences() -> Preferences {
        let preferencesController = PreferencesController()
        let preferences = Preferences(
            isAirdrop: preferencesController.get(for: .airdropNotifications)
        )
        return preferences
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
