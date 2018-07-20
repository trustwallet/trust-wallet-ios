// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Eureka
import StoreKit
import TrustCore

protocol SettingsViewControllerDelegate: class {
    func didAction(action: SettingsAction, in viewController: SettingsViewController)
}

final class SettingsViewController: FormViewController, Coordinator {
    var coordinators: [Coordinator] = []

    struct Values {
        static let currencyPopularKey = "0"
        static let currencyAllKey = "1"
        static let passcodeRow = "PasscodeRow"
    }

    private var config = Config()
    private var lock = Lock()
    private let helpUsCoordinator = HelpUsCoordinator()

    weak var delegate: SettingsViewControllerDelegate?

    var isPasscodeEnabled: Bool {
        return lock.isPasscodeSet()
    }

    lazy var viewModel: SettingsViewModel = {
        return SettingsViewModel(isDebug: isDebug)
    }()

    lazy var autoLockRow: PushRow<AutoLock> = {
        return PushRow<AutoLock> { [weak self] in
            guard let strongSelf = self else {
                return
            }
            $0.title = strongSelf.viewModel.autoLockTitle
            $0.options = strongSelf.viewModel.autoLockOptions
            $0.value = strongSelf.lock.getAutoLockType()
            $0.selectorTitle = strongSelf.viewModel.autoLockTitle
            $0.displayValueFor = { value in
                return value?.displayName
            }
            $0.hidden = Condition.function([Values.passcodeRow], { form in
                return !((form.rowBy(tag: Values.passcodeRow) as? SwitchRow)?.value ?? false)
            })
        }.onChange { [weak self] row in
            let autoLockType = row.value ?? AutoLock.immediate
            self?.lock.setAutoLockType(type: autoLockType)
            self?.lock.removeAutoLockTime()
        }.onPresent { _, selectorController in
            selectorController.enableDeselection = false
        }.cellSetup { cell, _ in
            cell.imageView?.image = R.image.settings_colorful_auto()
        }
    }()

    let session: WalletSession
    let keystore: Keystore

    init(
        session: WalletSession,
        keystore: Keystore
    ) {
        self.session = session
        self.keystore = keystore
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = NSLocalizedString("settings.navigation.title", value: "Settings", comment: "")

        form = Section()

            <<< walletsRow(for: session.account.address)

            +++ Section(NSLocalizedString("settings.security.label.title", value: "Security", comment: ""))

            <<< SwitchRow(Values.passcodeRow) { [weak self] in
                $0.title = self?.viewModel.passcodeTitle
                $0.value = self?.isPasscodeEnabled
            }.onChange { [unowned self] row in
                if row.value == true {
                    self.setPasscode { result in
                        row.value = result
                        row.updateCell()
                    }
                } else {
                    self.lock.deletePasscode()
                    self.updateAutoLockRow(with: AutoLock.immediate)
                }
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_colorful_security()
            }

            <<< autoLockRow

            <<< AppFormAppearance.button { [weak self] row in
                row.cellStyle = .value1
                row.presentationMode = .show(controllerProvider: ControllerProvider<UIViewController>.callback {
                    let controller = NotificationsViewController()
                    controller.didChange = { [weak self] change in
                        self?.run(action: .pushNotifications(change))
                    }
                    return controller
                }, onDismiss: { _ in
            })
            }.cellUpdate { cell, _ in
                cell.imageView?.image = R.image.settings_colorful_notifications()
                cell.textLabel?.text = R.string.localizable.settingsPushNotificationsTitle()
                cell.accessoryType = .disclosureIndicator
            }

            +++ Section()

            <<< currencyRow()
            <<< browserRow()
            <<< privacyRow()

            +++ Section()

            <<< developersRow()

            +++ Section(R.string.localizable.settingsJoinCommunityLabelTitle())

            <<< linkProvider(type: .twitter)
            <<< linkProvider(type: .telegram)
            <<< linkProvider(type: .facebook)
            <<< linkProvider(type: .discord)

            +++ Section(R.string.localizable.settingsSupportTitle())

            <<< AppFormAppearance.button { button in
                button.title = R.string.localizable.shareWithFriends()
                button.cell.imageView?.image = R.image.settings_colorful_share()
            }.onCellSelection { [unowned self] cell, _  in
                self.helpUsCoordinator.presentSharing(in: self, from: cell.contentView)
            }

            +++ Section()

            <<< aboutRow()
            <<< supportRow()

            +++ Section()

            <<< TextRow {
                $0.title = R.string.localizable.settingsVersionLabelTitle()
                $0.value = Bundle.main.fullVersion
                $0.disabled = true
            }
    }

    private func walletsRow(for address: Address) -> ButtonRow {
        return AppFormAppearance.button { [weak self] row in
            row.cellStyle = .value1
        }.cellUpdate { cell, _ in
            cell.textLabel?.textColor = .black
            cell.imageView?.image = R.image.settings_colorful_wallets()
            cell.textLabel?.text = R.string.localizable.wallets()
            cell.detailTextLabel?.text = String(address.description.prefix(10)) + "..."
            cell.accessoryType = .disclosureIndicator
        }.onCellSelection { (cell, row) in
            self.delegate?.didAction(action: .wallets, in: self)
        }
    }

    private func currencyRow() -> PushRow<Currency> {
        return PushRow<Currency> { [weak self] in
            $0.title = self?.viewModel.currencyTitle
            $0.selectorTitle = self?.viewModel.currencyTitle
            $0.options = self?.viewModel.currency
            $0.value = self?.config.currency
            $0.displayValueFor = { value in
                let currencyCode = value?.rawValue ?? ""
                return currencyCode + " - " + (NSLocale.current.localizedString(forCurrencyCode: currencyCode) ?? "")
            }
        }.onChange { [weak self]  row in
            guard let value = row.value else { return }
            self?.config.currency = value
            self?.run(action: .currency)
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
            cell.imageView?.image = R.image.settings_colorful_currency()
        }
    }

    private func supportRow() -> ButtonRow {
        return AppFormAppearance.button { row in
            row.cellStyle = .value1
            row.presentationMode = .show(controllerProvider: ControllerProvider<UIViewController>.callback { [weak self] in
                let controller = SupportViewController()
                controller.delegate = self
                return controller
            }, onDismiss: { _ in })
        }.cellUpdate { cell, _ in
            cell.textLabel?.textColor = .black
            cell.imageView?.image = R.image.settings_colorful_support()
            cell.textLabel?.text = NSLocalizedString("settings.support.title", value: "Support", comment: "")
            cell.accessoryType = .disclosureIndicator
        }
    }

    private func aboutRow() -> ButtonRow {
        return AppFormAppearance.button { row in
            row.cellStyle = .value1
            row.presentationMode = .show(controllerProvider: ControllerProvider<UIViewController>.callback { [weak self] in
                let controller = AboutViewController()
                controller.delegate = self
                return controller
            }, onDismiss: { _ in })
        }.cellUpdate { cell, _ in
            cell.textLabel?.textColor = .black
            cell.imageView?.image = R.image.settings_colorful_about()
            cell.textLabel?.text = NSLocalizedString("settings.about.title", value: "About", comment: "")
            cell.accessoryType = .disclosureIndicator
        }
    }

    private func browserRow() -> ButtonRow {
        return AppFormAppearance.button { row in
            row.cellStyle = .value1
            row.presentationMode = .show(controllerProvider:ControllerProvider<UIViewController>.callback { [weak self] in
                let controller = BrowserConfigurationViewController()
                controller.delegate = self
                return controller
            }, onDismiss: nil)
        }.cellUpdate { cell, _ in
            cell.textLabel?.textColor = .black
            cell.imageView?.image = R.image.settings_colorful_dappbrowser()
            cell.textLabel?.text = NSLocalizedString("settings.browser.title", value: "DApp Browser", comment: "")
            cell.accessoryType = .disclosureIndicator
        }
    }

    private func privacyRow() -> ButtonRow {
        return AppFormAppearance.button { row in
            row.cellStyle = .value1
            row.presentationMode = .show(controllerProvider:ControllerProvider<UIViewController>.callback {
                return PrivacyViewController()
            }, onDismiss: nil)
        }.cellUpdate { cell, _ in
            cell.imageView?.image = R.image.settings_colorful_privacy()
            cell.textLabel?.text = R.string.localizable.settingsPrivacyTitle()
            cell.accessoryType = .disclosureIndicator
        }
    }

    private func developersRow() -> ButtonRow {
        return AppFormAppearance.button { row in
            row.cellStyle = .value1
            row.presentationMode = .show(controllerProvider:ControllerProvider<UIViewController>.callback {
                let controller = DeveloperViewController()
                controller.delegate = self
                return controller
            }, onDismiss: nil)
        }.cellUpdate { cell, _ in
            cell.imageView?.image = R.image.settings_colorful_privacy()
            cell.textLabel?.text = R.string.localizable.developer()
            cell.accessoryType = .disclosureIndicator
        }
    }

    func setPasscode(completion: ((Bool) -> Void)? = .none) {
        let coordinator = LockCreatePasscodeCoordinator(
            model: LockCreatePasscodeViewModel()
        )
        coordinator.delegate = self
        coordinator.start()
        coordinator.lockViewController.willFinishWithResult = { [weak self] result in
            if result {
                let type = AutoLock.immediate
                self?.lock.setAutoLockType(type: type)
                self?.updateAutoLockRow(with: type)
            }
            completion?(result)
            self?.navigationController?.dismiss(animated: true, completion: nil)
        }
        addCoordinator(coordinator)
        navigationController?.present(coordinator.navigationController, animated: true, completion: nil)
    }

    private func linkProvider(
        type: URLServiceProvider
    ) -> ButtonRow {
        return AppFormAppearance.button {
            $0.title = type.title
        }.onCellSelection { [weak self] _, _ in
            guard let `self` = self else { return }
            if let localURL = type.localURL, UIApplication.shared.canOpenURL(localURL) {
                UIApplication.shared.open(localURL, options: [:], completionHandler: .none)
            } else {
                self.openURLInBrowser(type.remoteURL)
            }
        }.cellSetup { cell, _ in
            cell.imageView?.image = type.image
        }.cellUpdate { cell, _ in
            cell.accessoryType = .disclosureIndicator
            cell.textLabel?.textAlignment = .left
            cell.textLabel?.textColor = .black
        }
    }

    private func updateAutoLockRow(with type: AutoLock) {
        self.autoLockRow.value = type
        self.autoLockRow.reload()
    }

    func run(action: SettingsAction) {
        delegate?.didAction(action: action, in: self)
    }

    func openURLInBrowser(_ url: URL) {
        self.delegate?.didAction(action: .openURL(url), in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SettingsViewController: LockCreatePasscodeCoordinatorDelegate {
    func didCancel(in coordinator: LockCreatePasscodeCoordinator) {
        coordinator.lockViewController.willFinishWithResult?(false)
        navigationController?.dismiss(animated: true, completion: nil)
        removeCoordinator(coordinator)
    }
}

extension SettingsViewController: SupportViewControllerDelegate {
    func didPressURL(_ url: URL, in controller: SupportViewController) {
        openURLInBrowser(url)
    }
}

extension SettingsViewController: AboutViewControllerDelegate {
    func didPressURL(_ url: URL, in controller: AboutViewController) {
        openURLInBrowser(url)
    }
}

extension SettingsViewController: BrowserConfigurationViewControllerDelegate {
    func didPressDeleteCache(in controller: BrowserConfigurationViewController) {
        delegate?.didAction(action: .clearBrowserCache, in: self)
    }
}

extension SettingsViewController: Scrollable {
    func scrollOnTop() {
        guard isViewLoaded else { return }
        tableView.scrollOnTop()
    }
}

extension SettingsViewController: DeveloperViewControllerDelegate {
}
