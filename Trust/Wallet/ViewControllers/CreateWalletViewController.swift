// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import BonMot
import OnePasswordExtension

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
       if OnePasswordExtension.shared().isAppExtensionAvailable() {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: R.image.onepasswordButton(),
                style: .done,
                target: self,
                action: #selector(onePasswordCreate)
            )
       }

        form +++
            Section {
                var header = HeaderFooterView<InfoHeaderView>(.class)
                header.height = { 90 }
                header.onSetupView = { (view, section) -> Void in
                    view.label.attributedText = "Password will be used to protect your digital wallet".styled(
                        with:
                        .color(UIColor(hex: "6e6e72")),
                        .font(UIFont.systemFont(ofSize: 14, weight: UIFontWeightRegular)),
                        .lineHeightMultiple(1.25)
                    )
                    view.logoImageView.image = R.image.create_wallet()
                }
                $0.header = header
            }

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
            +++ Section("Already have a wallet?")
            <<< ButtonRow("Import") {
                $0.title = $0.tag
            }.onCellSelection { [unowned self] (_, _) in
                self.importWallet()
            }
    }

    func handleCreatedAccount(account: Account) {
        delegate?.didCreateAccount(account: account, in: self)
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
        handleCreatedAccount(account: account)
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

    func onePasswordCreate() {
        let newPasssword = NSUUID().uuidString
        let account = keystore.createAccout(password: newPasssword)
        let keystoreString: String = {
            let value = keystore.export(account: account, password: newPasssword)
            switch value {
            case .success(let string):
                return string
            case .failure: return ""
            }
        }()

        let formattedPassword = OnePasswordConverter.toPassword(password: newPasssword, keystore: keystoreString)

        OnePasswordExtension().storeLogin(
            forURLString: OnePasswordConfig.url,
            loginDetails: [
                AppExtensionUsernameKey: account.address.address,
                AppExtensionPasswordKey: formattedPassword,
                AppExtensionNotesKey: "Ethereum wallet has been stored here. Format: password-trust-keystore. -trust- - is a divider between password and keystore",
            ],
            passwordGenerationOptions: [:],
            for: self,
            sender: nil
        ) { results, error in
            let results = results ?? [:]
            if error != nil {
                let _ = self.keystore.delete(account: account, password: newPasssword)
            } else {
                let updatedPassword = results[AppExtensionPasswordKey] as? String ?? ""
                let result = OnePasswordConverter.fromPassword(password: updatedPassword)
                switch result {
                case .success(let password, _):
                    if password == newPasssword {
                        self.handleCreatedAccount(account: account)
                    } else {
                        let result = self.keystore.updateAccount(account: account, password: password, newPassword: updatedPassword)
                        switch result {
                        case .success:
                            self.handleCreatedAccount(account: account)
                        case .failure(let error):
                            self.displayError(error: error)
                        }
                    }
                case .failure(let error):
                    self.displayError(error: error)
                }
            }
        }
    }
}
