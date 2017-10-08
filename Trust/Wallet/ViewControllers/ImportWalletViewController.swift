// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import OnePasswordExtension

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

    var keystoreRow: TextAreaRow? {
        return form.rowBy(tag: Values.keystore)
    }

    var passwordRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.password)
    }

    lazy var onePasswordCoordinator: OnePasswordCoordinator = {
        return OnePasswordCoordinator(keystore: self.keystore)
    }()

    weak var delegate: ImportWalletViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title

        if OnePasswordExtension.shared().isAppExtensionAvailable() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: R.image.onepasswordButton(),
                style: .done,
                target: self,
                action: #selector(onePasswordImport)
            )
        }

        form = Section()

            <<< AppFormAppearance.textArea(tag: Values.keystore) {
                $0.placeholder = "Keystore JSON"
                $0.textAreaHeight = .fixed(cellHeight: 100)
                $0.add(rule: RuleRequired())
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.password) {
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.isSecureTextEntry = true
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "Password"
            }

            +++ Section("")

            <<< ButtonRow("Import") {
                $0.title = $0.tag
            }.onCellSelection { [unowned self] _, _ in
                self.importWallet()
            }
    }

    func didImport(account: Account) {
        delegate?.didImportAccount(account: account, in: self)
    }

    func importWallet() {
        let validatedError = keystoreRow?.section?.form?.validate()
        guard let errors = validatedError, errors.isEmpty else { return }

        let input = keystoreRow?.value ?? ""
        let password = passwordRow?.value ?? ""

        let result = keystore.importKeystore(value: input, password: password)
        switch result {
        case .success(let account):
            didImport(account: account)
        case .failure(let error):
            displayError(error: error)
        }
    }

    func onePasswordImport() {
        onePasswordCoordinator.importWallet(in: self) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let password, let keystore):
                self.keystoreRow?.value = keystore
                self.keystoreRow?.reload()
                self.passwordRow?.value = password
                self.passwordRow?.reload()
                self.importWallet()
            case .failure(let error):
                self.displayError(error: error)
            }
        }
    }
}
