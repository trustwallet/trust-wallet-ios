// Copyright SIX DAY LLC, Inc. All rights reserved.

import UIKit
import Eureka

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
            
            <<< ButtonRow("Export Private Key") {
                $0.title = $0.tag
            }.onCellSelection { [weak self] (cell, row) in
                self?.run(action: .exportPrivateKey)
            }.cellUpdate { cell, row in
                cell.textLabel?.textAlignment = .left
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
}
