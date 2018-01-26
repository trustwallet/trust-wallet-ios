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
        static let currencyPopularKey = "0"
        static let currencyAllKey = "1"
    }

    private var config = Config()
    private let helpUsCoordinator = HelpUsCoordinator()
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
    let session: WalletSession

    init(session: WalletSession) {
        self.session = session
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // swiftlint:disable:next function_body_length
    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("settings.navigation.title", value: "Settings", comment: "")
        let account = session.account

        form = Section()

            <<< PushRow<RPCServer> {
                $0.title = viewModel.networkTitle
                $0.options = viewModel.servers
                $0.value = RPCServer(chainID: config.chainID)
                $0.selectorTitle = viewModel.networkTitle
                $0.displayValueFor = { value in
                    return value?.name
                }
            }.onChange { row in
                self.config.chainID = row.value?.chainID ?? RPCServer.main.chainID
                self.run(action: .RPCServer)
            }.onPresent { _, selectorController in
                selectorController.enableDeselection = false
                selectorController.sectionKeyForValue = { option in
                    switch option {
                    case .main, .classic, .poa: return ""
                    case .kovan, .ropsten, .rinkeby, .sokol: return NSLocalizedString("settings.network.test.label.title", value: "Test", comment: "")
                    }
                }
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_server()
            }

            <<< AppFormAppearance.button { button in
                button.cellStyle = .value1
            }.onCellSelection { [unowned self] _, _ in
                self.run(action: .wallets)
            }.cellUpdate { cell, _ in
                cell.textLabel?.textColor = .black
                cell.imageView?.image = R.image.settings_wallet()
                cell.textLabel?.text = NSLocalizedString("settings.wallets.button.title", value: "Wallets", comment: "")
                cell.detailTextLabel?.text = String(account.address.description.prefix(10)) + "..."
                cell.accessoryType = .disclosureIndicator
            }

            +++ Section()

            <<< PushRow<Currency> {
                $0.title = viewModel.currencyTitle
                $0.selectorTitle = viewModel.currencyTitle
                $0.options = viewModel.currency
                $0.value = config.currency
                $0.displayValueFor = { value in
                    let currencyCode = value?.rawValue ?? ""
                    if #available(iOS 10.0, *) {
                        return currencyCode + " - " + (NSLocale.current.localizedString(forCurrencyCode: currencyCode) ?? "")
                    } else {
                        return currencyCode
                    }
                }
            }.onChange { row in
                guard let value = row.value else { return }
                self.config.currency = value
                self.run(action: .currency)
            }.onPresent { _, selectorController in
                selectorController.enableDeselection = false
                selectorController.sectionKeyForValue = { option in
                    switch option {
                    case .USD, .EUR, .GBP, .AUD, .RUB: return Values.currencyPopularKey
                    default: return Values.currencyAllKey
                    }
                }
                selectorController.sectionHeaderTitleForKey = { option in
                    switch option {
                    case Values.currencyPopularKey:
                        return NSLocalizedString("settings.currency.popular.label.title", value: "Popular", comment: "")
                    case Values.currencyAllKey:
                        return NSLocalizedString("settings.currency.all.label.title", value: "All", comment: "")
                    default: return ""
                    }
                }
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settingsCurrency()
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
                button.title = NSLocalizedString("settings.shareWithFriends.button.title", value: "Share With Friends", comment: "")
                button.cell.imageView?.image = R.image.settingsShare()
            }.onCellSelection { [unowned self] cell, _  in
                self.helpUsCoordinator.presentSharing(in: self, from: cell.contentView)
            }

            <<< AppFormAppearance.button { button in
                button.title = NSLocalizedString("settings.rateUsAppStore.button.title", value: "Rate Us on App Store", comment: "")
            }.onCellSelection { _, _  in
                self.helpUsCoordinator.rateUs()
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
                UIApplication.shared.open(localURL, options: [:], completionHandler: .none)
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
