// Copyright SIX DAY LLC, Inc. All rights reserved.

import UIKit
import Eureka
import SafariServices

enum SettingsAction {
    case exportPrivateKey
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
            }.onCellSelection { [unowned self] (cell, row) in
                self.run(action: .exportPrivateKey)
            }
            
            +++ Section()
            
            <<< PushRow<String> {
                $0.title = "RPC Server"
                $0.options = [
                    RPCServer.main.name,
                    RPCServer.ropsten.name,
                    RPCServer.kovan.name,
                    RPCServer.rinkeby.name
                ]
                $0.value = RPCServer(chainID: config.chainID).name
            }.onChange { row in
                self.config.chainID = RPCServer(name: row.value ?? "").chainID
            }.onPresent { form, selectorController in
                selectorController.enableDeselection = false
            }
            
            +++ Section("Open source development")
            
            <<< AppFormAppearance.button() {
                $0.title = "iOS Client"
                $0.value = "https://github.com/TrustWallet/trust-wallet-ios"
            }.onCellSelection { [unowned self] (cell, row) in
                self.openURL(URL(string: row.value!)!)
            }
            
            <<< AppFormAppearance.button() {
                $0.title = "Road Map"
                $0.value = "https://github.com/TrustWallet/trust-wallet-ios/projects/1"
            }.onCellSelection { [unowned self] (cell, row) in
                self.openURL(URL(string: row.value!)!)
            }
            
            +++ Section()
        
            <<< TextRow() {
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
    
    func run(action: SettingsAction) {
        delegate?.didAction(action: action, in: self)
    }
    
    func openURL(_ url: URL) {
        let controller = SFSafariViewController(url: url)
        present(controller, animated: true, completion: nil)
    }
}
