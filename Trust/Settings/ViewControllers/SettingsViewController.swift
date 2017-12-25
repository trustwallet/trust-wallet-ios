// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import VENTouchLock
import StoreKit
import MessageUI

protocol SettingsViewControllerDelegate: class {
    func didAction(action: SettingsAction, in viewController: SettingsViewController)
}

class SettingsViewController: FormViewController {

    struct Values {
        static let donationAddress = Address(address: "0x9f8284ce2cf0c8ce10685f537b1fff418104a317")
    }

    private var config = Config()

    weak var delegate: SettingsViewControllerDelegate?

    var isPasscodeEnabled: Bool {
        return VENTouchLock.sharedInstance().isPasscodeSet()
    }

    static var isPushNotificationEnabled: Bool {
        guard let settings = UIApplication.shared.currentUserNotificationSettings
            else {
                return false
        }
        return UIApplication.shared.isRegisteredForRemoteNotifications && !settings.types.isEmpty
    }

    lazy var viewModel: SettingsViewModel = {
        return SettingsViewModel(isDebug: isDebug)
    }()

    // swiftlint:disable:next function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("settings.navigation.title", value: "Settings", comment: "")

        form = Section()

            <<< PushRow<String> {
                $0.title = viewModel.networkTitle
                $0.options = viewModel.servers
                $0.value = RPCServer(chainID: config.chainID).name
                $0.selectorTitle = viewModel.networkTitle
                $0.displayValueFor = { value in
                    let network = RPCServer(name: value ?? "")
                    return network.name + (network.isTestNetwork ? " (Test)" : "")
                }
            }.onChange { row in
                self.config.chainID = RPCServer(name: row.value ?? "").chainID
                self.run(action: .RPCServer)
            }.onPresent { _, selectorController in
                selectorController.enableDeselection = false
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_server()
            }

            +++ Section(NSLocalizedString("settings.security.label.title", value: "Security", comment: ""))

            <<< SwitchRow {
                $0.title = viewModel.passcodeTitle
                $0.value = self.isPasscodeEnabled
            }.onChange { [unowned self] row in
                if row.value == true {
                    self.setPasscode { result in
                        row.value = result
                        row.updateCell()
                    }
                    VENTouchLock.setShouldUseTouchID(true)
                    VENTouchLock.sharedInstance().backgroundLockVisible = false
                } else {
                    VENTouchLock.sharedInstance().deletePasscode()
                }
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_lock()
            }

            <<< SwitchRow {
                $0.title = NSLocalizedString("settings.pushNotifications.button.title", value: "Push Notifications", comment: "")
                $0.value = SettingsViewController.isPushNotificationEnabled
            }.onChange { [unowned self] row in
                let enabled = row.value ?? false
                self.run(action: .pushNotifications(enabled: enabled))
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_push_notifications()
            }

            +++ Section(NSLocalizedString("settings.openSourceDevelopment.label.title", value: "Open Source Development", comment: ""))

            <<< link(
                title: NSLocalizedString("settings.sourceCode.button.title", value: "Source Code", comment: ""),
                value: "https://github.com/TrustWallet/trust-wallet-ios",
                image: R.image.settings_open_source()
            )

            <<< link(
                title: NSLocalizedString("settings.reportBug.button.title", value: "Report a Bug", comment: ""),
                value: "https://github.com/TrustWallet/trust-wallet-ios/issues/new",
                image: R.image.settings_bug()
            )

            +++ Section(NSLocalizedString("settings.community.label.title", value: "Community", comment: ""))

            <<< linkProvider(type: .twitter)
            <<< linkProvider(type: .telegram)
            <<< linkProvider(type: .facebook)

            +++ Section(NSLocalizedString("settings.support.label.title", value: "Support", comment: ""))

            <<< AppFormAppearance.button { button in
                button.title = NSLocalizedString("settings.rateUsAppStore.button.title", value: "Rate Us on App Store", comment: "")
            }.onCellSelection { _, _  in
                if #available(iOS 10.3, *) { SKStoreReviewController.requestReview() } else {
                    UIApplication.shared.openURL(URL(string: "itms-apps://itunes.apple.com/app/id1288339409")!)
                }
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_rating()
            }

            <<< AppFormAppearance.button { button in
                button.title = NSLocalizedString("settings.emailUs.button.title", value: "Email Us", comment: "")
            }.onCellSelection { _, _  in
                self.sendUsEmail()
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_email()
            }

            <<< AppFormAppearance.button { button in
                button.title = NSLocalizedString("settings.donate.button.title", value: "Donate", comment: "")
            }.onCellSelection { [unowned self] _, _ in
                self.run(action: .donate(address: Values.donationAddress))
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_donate()
            }

            <<< link(
                title: NSLocalizedString("settings.privacyPolicy.button.title", value: "Privacy Policy", comment: ""),
                value: "https://trustwalletapp.com/privacy-policy.html",
                image: R.image.settings_privacy_policy()
            )

            <<< link(
                title: NSLocalizedString("settings.termsOfService.button.title", value: "Terms of Service", comment: ""),
                value: "https://trustwalletapp.com/terms.html",
                image: R.image.settings_terms()
            )

            +++ Section()

            <<< TextRow {
                $0.title = NSLocalizedString("settings.version.label.title", value: "Version", comment: "")
                $0.value = version()
                $0.disabled = true
            }
    }

    func setPasscode(completion: ((Bool) -> Void)? = .none) {
        let controller = VENTouchLockCreatePasscodeViewController()
        controller.willFinishWithResult = { result in
            completion?(result)
            controller.dismiss(animated: true, completion: nil)
        }
        present(controller.embeddedInNavigationController(), animated: true, completion: nil)
    }

    private func version() -> String {
        let versionNumber = Bundle.main.versionNumber ?? ""
        let buildNumber = Bundle.main.buildNumber ?? ""
        return "\(versionNumber) (\(buildNumber))"
    }

    private func linkProvider(
        type: URLServiceProvider
    ) -> ButtonRow {
        return AppFormAppearance.button {
            $0.title = type.title
        }.onCellSelection { [unowned self] _, _ in
            if let localURL = type.localURL, UIApplication.shared.canOpenURL(localURL) {
                UIApplication.shared.openURL(localURL)
            } else {
                self.openURL(type.remoteURL)
            }
        }.cellSetup { cell, _ in
            cell.imageView?.image = type.image
        }
    }

    private func link(
        title: String,
        value: String,
        image: UIImage?
    ) -> ButtonRow {
        return AppFormAppearance.button {
            $0.title = title
            $0.value = value
        }.onCellSelection { [unowned self] (_, row) in
            guard let value = row.value, let url = URL(string: value) else { return }
            self.openURL(url)
        }.cellSetup { cell, _ in
            cell.imageView?.image = image
        }
    }

    func run(action: SettingsAction) {
        delegate?.didAction(action: action, in: self)
    }

    func sendUsEmail() {
        let composerController = MFMailComposeViewController()
        composerController.mailComposeDelegate = self
        composerController.setToRecipients([Constants.supportEmail])
        composerController.setSubject(NSLocalizedString("settings.feedback.email.title", value: "Trust Feedback", comment: ""))
        composerController.setMessageBody("", isHTML: false)

        if MFMailComposeViewController.canSendMail() {
            present(composerController, animated: true, completion: nil)
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
