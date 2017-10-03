// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import SafariServices

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

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Settings"

        form = Section("Export")

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

            +++ Section("Open source development")

            <<< link(
                title: "Source Code",
                value: "https://github.com/TrustWallet/trust-wallet-ios",
                image: R.image.settings_open_source()
            )

            <<< link(
                title: "Road Map",
                value: "https://github.com/TrustWallet/trust-wallet-ios/projects/1",
                image: R.image.settings_road_map()
            )

            <<< link(
                title: "Report a Bug",
                value: "https://github.com/TrustWallet/trust-wallet-ios/issues/new",
                image: R.image.settings_bug()
            )

            <<< link(
                title: "Twitter",
                value: "https://twitter.com/thetrustwallet",
                image: R.image.settings_twitter()
            )

            +++ Section()

            <<< TextRow {
                $0.title = "Version"
                $0.value = version()
                $0.disabled = true
            }
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
