// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import OnePasswordExtension
import BonMot

protocol ImportWalletViewControllerDelegate: class {
    func didImportAccount(account: Account, in viewController: ImportWalletViewController)
}

class ImportWalletViewController: FormViewController {

    private let keystore = EtherKeystore()
    private let viewModel = ImportWalletViewModel()

    struct Values {
        static let segment = "segment"
        static let keystore = "keystore"
        static let privateKey = "privateKey"
        static let password = "password"
    }

    var segmentRow: SegmentedRow<String>? {
        return form.rowBy(tag: Values.segment)
    }

    var keystoreRow: TextAreaRow? {
        return form.rowBy(tag: Values.keystore)
    }

    var privateKeyRow: TextAreaRow? {
        return form.rowBy(tag: Values.privateKey)
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

        //Demo purpose

        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Demo", style: .done, target: self, action: #selector(self.demo))
        }

        title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.import_options(), style: .done, target: self, action: #selector(importOptions))

//        if OnePasswordExtension.shared().isAppExtensionAvailable() {
//            self.navigationItem.rightBarButtonItem = UIBarButtonItem(
//                image: R.image.onepasswordButton(),
//                style: .done,
//                target: self,
//                action: #selector(onePasswordImport)
//            )
//        }

        form
            +++ Section {
                var header = HeaderFooterView<InfoHeaderView>(.class)
                header.height = { 90 }
                header.onSetupView = { (view, section) -> Void in
                    view.label.attributedText = "Importing wallet as easy as creating".styled(
                        with:
                        .color(UIColor(hex: "6e6e72")),
                        .font(UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)),
                        .lineHeightMultiple(1.25)
                    )
                    view.logoImageView.image = R.image.create_wallet_import()
                }
                $0.header = header
            }

            <<< SegmentedRow<String>(Values.segment) {
                $0.options = [
                    ImportSelectionType.keystore.title,
                    ImportSelectionType.privateKey.title,
                ]
                $0.value = ImportSelectionType.keystore.title
            }

            <<< AppFormAppearance.textArea(tag: Values.keystore) {
                $0.placeholder = "Keystore JSON"
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())

                $0.hidden = Eureka.Condition.function([Values.segment], { _ in
                    return self.segmentRow?.value != ImportSelectionType.keystore.title
                })
            }

            <<< AppFormAppearance.textArea(tag: Values.privateKey) {
                $0.placeholder = "Private Key"
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())
                $0.add(rule: PrivateKeyRule())
                $0.hidden = Eureka.Condition.function([Values.segment], { _ in
                    return self.segmentRow?.value != ImportSelectionType.privateKey.title
                })
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.password) {
                $0.validationOptions = .validatesOnDemand
                $0.hidden = Eureka.Condition.function([Values.segment], { _ in
                    return self.segmentRow?.value != ImportSelectionType.keystore.title
                })
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

        let keystoreInput = keystoreRow?.value?.trimmed ?? ""
        let privateKeyInput = privateKeyRow?.value?.trimmed ?? ""
        let password = passwordRow?.value ?? ""

        displayLoading(text: NSLocalizedString("importWallet.importingIndicatorTitle", value: "Importing wallet...", comment: ""), animated: false)

        let type = ImportSelectionType(title: segmentRow?.value)
        let importType: ImportType = {
            switch type {
            case .keystore:
                return .keystore(string: keystoreInput, password: password)
            case .privateKey:
                return .privateKey(privateKey: privateKeyInput, password: UUID().uuidString)
            }
        }()

        keystore.importWallet(type: importType) { result in
            self.hideLoading(animated: false)
            switch result {
            case .success(let account):
                self.didImport(account: account)
            case .failure(let error):
                self.displayError(error: error)
            }
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

    @objc func demo() {
        //Used for taking screenshots to the App Store by snapshot
        let demoAccount = Account(
            address: Address(address: "0xD663bE6b87A992C5245F054D32C7f5e99f5aCc47")
        )
        delegate?.didImportAccount(account: demoAccount, in: self)
    }

    @objc func importOptions(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Import Wallet Options", message: .none, preferredStyle: .actionSheet)
        alertController.popoverPresentationController?.barButtonItem = sender
        alertController.addAction(UIAlertAction(title: "iCloud/Dropbox/Google Cloud", style: .default) { _ in
            self.showDocumentPicker()
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .destructive) { _ in })
        present(alertController, animated: true)
    }

    func showDocumentPicker() {
        let types = ["public.text", "public.content", "public.item", "public.data"]
        let controller = UIDocumentPickerViewController(documentTypes: types, in: .import)
        controller.delegate = self
        controller.modalPresentationStyle = .formSheet
        present(controller, animated: true, completion: nil)
    }
}

extension ImportWalletViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            let text = try? String(contentsOfFile: url.path)
            keystoreRow?.value = text
            keystoreRow?.reload()
        }
    }
}
