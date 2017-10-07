// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import SafariServices
import VENTouchLock

enum SettingsAction {
    case exportPrivateKey
    case RPCServer
}

protocol SettingsViewControllerDelegate: class {
    func didAction(action: SettingsAction, in viewController: SettingsViewController)
}

class SettingsViewController: FormViewController {

    private var config = Config()

    weak var delegate: SettingsViewControllerDelegate?

    var isPasscodeEnabled: Bool {
        return VENTouchLock.sharedInstance().isPasscodeSet()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"

        form = Section(header:"Export", footer: "Keep it secure and never share it with anyone.")

            <<< AppFormAppearance.button("Export Private Key") {
                $0.title = $0.tag
            }.onCellSelection { [unowned self] (_, _) in
                self.run(action: .exportPrivateKey)
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_export()
            }

            +++ Section()

            <<< PushRow<String> {
                $0.title = "RPC Server"
                $0.options = [
                    RPCServer.main.name,
                    RPCServer.ropsten.name,
                    RPCServer.kovan.name,
                    RPCServer.rinkeby.name,
                ]
                $0.value = RPCServer(chainID: config.chainID).name
            }.onChange { row in
                self.config.chainID = RPCServer(name: row.value ?? "").chainID
                self.run(action: .RPCServer)
            }.onPresent { _, selectorController in
                selectorController.enableDeselection = false
            }.cellSetup { cell, _ in
                cell.imageView?.image = R.image.settings_server()
            }

            +++ Section("Security")

            <<< SwitchRow {
                $0.title = "Passcode / Touch ID"
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

            +++ Section("Open source development")

            <<< link(
                title: "Source Code",
                value: "https://github.com/TrustWallet/trust-wallet-ios",
                image: R.image.settings_open_source()
            )

            <<< link(
                title: "Report a Bug",
                value: "https://github.com/TrustWallet/trust-wallet-ios/issues/new",
                image: R.image.settings_bug()
            )

            +++ Section("Community")

            <<< link(
                title: "Twitter",
                value: "https://twitter.com/trustwalletapp",
                image: R.image.settings_twitter()
            )

            <<< link(
                title: "Telegram Group",
                value: "https://t.me/joinchat/AAMtrQ_wtd918mm_mU0BRQ",
                image: R.image.settings_telegram()
            )

            +++ Section()

            <<< TextRow {
                $0.title = "Version"
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

    func openURL(_ url: URL) {
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }
}
