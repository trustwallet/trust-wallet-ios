// Copyright SIX DAY LLC, Inc. All rights reserved.

import UIKit
import Eureka

protocol ImportWalletViewControllerDelegate: class {
    func didImportAccount(account: Account, in viewController: ImportWalletViewController)
}

class ImportWalletViewController: FormViewController {

    private let keystore = EtherKeystore()
    private let viewModel = ImportWalletViewModel()
    
    struct Values {
        static let keystore = "keystore"
        static let password = "password"
    }
    
    weak var delegate: ImportWalletViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        
        form = Section()
            
            +++ Section("Keystore")
            
            <<< AppFormAppearance.textArea(tag: Values.keystore) {
                $0.placeholder = "Keystore JSON"
                $0.textAreaHeight = .fixed(cellHeight: 100)
                $0.add(rule: RuleRequired())
            }
            
            <<< AppFormAppearance.textFieldFloat(tag: Values.password) {
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, row in
                cell.textField.isSecureTextEntry = true
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "Password"
            }
            
            +++ Section("")
            
            <<< ButtonRow("Import") {
                $0.title = $0.tag
            }.onCellSelection { [unowned self] (cell, row) in
                let errors = row.section?.form?.validate()
                if errors?.count == 0 {
                    self.importWallet()
                }
            }
    }
    
    func didImport(account: Account) {
        delegate?.didImportAccount(account: account, in: self)
    }
    
    func importWallet() {
    
        let keystoreRow: TextAreaRow? = form.rowBy(tag: Values.keystore)
        let passwordRow: TextFloatLabelRow? = form.rowBy(tag: Values.password)
        
        let input = keystoreRow?.value ?? ""
        let password = passwordRow?.value ?? ""
        
        let result = keystore.importKeystore(value: input, password: password)
        switch result{
        case .success(let account):
            didImport(account: account)
        case .failure(let error):
            displayError(error: error)
        }
    }
}
