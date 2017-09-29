// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka

protocol CreateWalletViewControllerDelegate: class {
    func didPressImport(in viewController: CreateWalletViewController)
    func didCreateAccount(account: Account, in viewController: CreateWalletViewController)
    func didCancel(in viewController: CreateWalletViewController)
}

class CreateWalletViewController: FormViewController {

    private let viewModel = CreateWalletViewModel()
    private let keystore = EtherKeystore()

    struct Values {
        static let password = "password"
        static let passwordRepeat = "passwordRepeat"
    }

    weak var delegate: CreateWalletViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        view.backgroundColor = .white

        //Demo purpose
        if isDebug() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Demo", style: .done, target: self, action: #selector(self.demo))
            }
        }

        form = Section()

            //+++ Section("New wallet")

            <<< AppFormAppearance.textFieldFloat(tag: Values.password) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.isSecureTextEntry = true
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "Password"
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.passwordRepeat) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.isSecureTextEntry = true
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "Confirm password"
            }

            +++ Section("")

            <<< ButtonRow("Create") {
                $0.title = $0.tag
            }.onCellSelection { [unowned self] (_, row) in
                let validatedError = row.section?.form?.validate()
                guard let errors = validatedError, errors.isEmpty else { return }
                self.startImport()
            }

            +++ Section("")
            +++ Section("")
            +++ Section("")
            <<< ButtonRow("I already have a wallet") {
                $0.title = $0.tag
            }.onCellSelection { [unowned self] (_, _) in
                self.importWallet()
            }
    }

    func startImport() {

        let passwordRow: TextFloatLabelRow? = form.rowBy(tag: Values.password)
        let passwordRepeatRow: TextFloatLabelRow? = form.rowBy(tag: Values.passwordRepeat)

        let password = passwordRow?.value ?? ""
        let passwordRepeat = passwordRepeatRow?.value ?? ""

        guard password == passwordRepeat else {
            return
        }

        let account = keystore.createAccout(password: password)

        delegate?.didCreateAccount(account: account, in: self)
    }

    func demo() {
        //Used for taking screenshots to the App Store by snapshot
        let demoAccount = Account(
            address: Address(address: "0xD663bE6b87A992C5245F054D32C7f5e99f5aCc47")
        )
        delegate?.didCreateAccount(account: demoAccount, in: self)
    }

    func importWallet() {
        delegate?.didPressImport(in: self)
    }
}
