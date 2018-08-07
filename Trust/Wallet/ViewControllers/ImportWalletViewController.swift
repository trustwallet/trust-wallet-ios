// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import Eureka
import TrustCore
import QRCodeReaderViewController

protocol ImportWalletViewControllerDelegate: class {
    func didImportAccount(account: WalletInfo, fields: [WalletInfoField], in viewController: ImportWalletViewController)
}

final class ImportWalletViewController: FormViewController {

    let keystore: Keystore
    let coin: Coin
    private lazy var viewModel: ImportWalletViewModel = {
        return ImportWalletViewModel(coin: coin)
    }()

    struct Values {
        static let segment = "segment"
        static let keystore = "keystore"
        static let privateKey = "privateKey"
        static let password = "password"
        static let name = "name"
        static let watch = "watch"
        static let phrase = "phrase"
    }

    var segmentRow: SegmentedRow<String>? {
        return form.rowBy(tag: Values.segment)
    }
    var keystoreRow: TextAreaRow? {
        return form.rowBy(tag: Values.keystore)
    }
    var phraseRow: TextAreaRow? {
        return form.rowBy(tag: Values.phrase)
    }
    var privateKeyRow: TextAreaRow? {
        return form.rowBy(tag: Values.privateKey)
    }
    var passwordRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.password)
    }
    var addressRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.watch)
    }
    var nameRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.name)
    }

    weak var delegate: ImportWalletViewControllerDelegate?

    init(
        keystore: Keystore,
        for coin: Coin
    ) {
        self.keystore = keystore
        self.coin = coin
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: R.image.qr_code_icon(), style: .done, target: self, action: #selector(openReader)),
        ]

        if UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                self.demo()
            }
        }

        let recipientRightView = AddressFieldView()
        recipientRightView.translatesAutoresizingMaskIntoConstraints = false
        recipientRightView.pasteButton.addTarget(self, action: #selector(pasteAddressAction), for: .touchUpInside)
        recipientRightView.qrButton.addTarget(self, action: #selector(openReader), for: .touchUpInside)

        let initialName = WalletInfo.initialName(index: keystore.wallets.count)

        form
            +++ Section()
            <<< SegmentedRow<String>(Values.segment) {
                $0.options = [
                    ImportSelectionType.mnemonic.title,
                    ImportSelectionType.keystore.title,
                    ImportSelectionType.privateKey.title,
                    ImportSelectionType.address.title,
                ]
                $0.value = ImportSelectionType.mnemonic.title
            }

            // Keystore JSON
            +++ Section(footer: ImportSelectionType.keystore.footerTitle) {
                $0.hidden = Eureka.Condition.function([Values.segment], { [weak self] _ in
                    return self?.segmentRow?.value != ImportSelectionType.keystore.title
                })
            }
            <<< AppFormAppearance.textArea(tag: Values.keystore) { [weak self] in
                $0.placeholder = self?.viewModel.keystorePlaceholder
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())
            }
            <<< AppFormAppearance.textFieldFloat(tag: Values.password) {
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.isSecureTextEntry = true
                cell.textField.textAlignment = .left
                cell.textField.placeholder = R.string.localizable.password()
            }

            // Private Key
            +++ Section(footer: ImportSelectionType.privateKey.footerTitle) {
                $0.hidden = Eureka.Condition.function([Values.segment], { [weak self] _ in
                    return self?.segmentRow?.value != ImportSelectionType.privateKey.title
                })
            }
            <<< AppFormAppearance.textArea(tag: Values.privateKey) { [weak self] in
                $0.placeholder = self?.viewModel.privateKeyPlaceholder
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())
                $0.add(rule: PrivateKeyRule())
            }

            // Mnemonic
            +++ Section(footer: ImportSelectionType.mnemonic.footerTitle) {
                $0.hidden = Eureka.Condition.function([Values.segment], { [weak self] _ in
                    return self?.segmentRow?.value != ImportSelectionType.mnemonic.title
                })
            }
            <<< AppFormAppearance.textArea(tag: Values.phrase) { [weak self] in
                $0.placeholder = self?.viewModel.mnemonicPlaceholder
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())
                $0.cell.textView?.autocapitalizationType = .none
            }

            // Watch
            +++ Section(footer: ImportSelectionType.address.footerTitle) {
                $0.hidden = Eureka.Condition.function([Values.segment], { [weak self] _ in
                    return self?.segmentRow?.value != ImportSelectionType.address.title
                })
            }
            <<< AppFormAppearance.textFieldFloat(tag: Values.watch) {
                $0.add(rule: RuleRequired())
                $0.add(rule: EthereumAddressRule())
            }.cellUpdate { [weak self] cell, _ in
                cell.textField.placeholder = self?.viewModel.watchAddressPlaceholder
                cell.textField.rightView = recipientRightView
                cell.textField.rightViewMode = .always
            }

            // Name
            +++ Section()
            <<< AppFormAppearance.textFieldFloat(tag: Values.name) {
                $0.value = initialName
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = R.string.localizable.name()
            }

            +++ Section()
            <<< ButtonRow(NSLocalizedString("importWallet.import.button.title", value: "Import", comment: "")) {
                $0.title = $0.tag
            }.onCellSelection { [weak self] _, _ in
                self?.importWallet()
            }
    }

    func didImport(account: WalletInfo, name: String) {
        delegate?.didImportAccount(account: account, fields: [
            .name(name),
            .backup(true),
        ], in: self)
    }

    func importWallet() {
        let validatedError = keystoreRow?.section?.form?.validate()
        guard let errors = validatedError, errors.isEmpty else { return }

        let keystoreInput = keystoreRow?.value?.trimmed ?? ""
        let privateKeyInput = privateKeyRow?.value?.trimmed ?? ""
        let password = passwordRow?.value ?? ""
        let addressInput = addressRow?.value?.trimmed ?? ""
        let phraseInput = phraseRow?.value?.trimmed ?? ""
        let name = nameRow?.value?.trimmed ?? ""
        let words = phraseInput.components(separatedBy: " ").map { $0.trimmed.lowercased() }

        displayLoading(text: NSLocalizedString("importWallet.importingIndicator.label.title", value: "Importing wallet...", comment: ""), animated: false)

        let type = ImportSelectionType(title: segmentRow?.value)
        let importType: ImportType = {
            switch type {
            case .keystore:
                return .keystore(string: keystoreInput, password: password)
            case .privateKey:
                return .privateKey(privateKey: privateKeyInput)
            case .mnemonic:
                return .mnemonic(words: words, password: password, derivationPath: coin.derivationPath(at: 0))
            case .address:
                let address = EthereumAddress(string: addressInput)! // EthereumAddress validated by form view.
                return .address(address: address)
            }
        }()

        keystore.importWallet(type: importType, coin: coin) { result in
            self.hideLoading(animated: false)
            switch result {
            case .success(let account):
                self.didImport(account: account, name: name)
            case .failure(let error):
                self.displayError(error: error)
            }
        }
    }

    @objc func demo() {
        //Used for taking screenshots to the App Store by snapshot
        let demoWallet = WalletType.address(Coin.ethereum, EthereumAddress(string: "0xD663bE6b87A992C5245F054D32C7f5e99f5aCc47")!)
        let walletInfo = WalletInfo(type: demoWallet, info: WalletObject.from(demoWallet))
        delegate?.didImportAccount(account: walletInfo, fields: [], in: self)
    }

    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    func setValueForCurrentField(string: String) {
        let type = ImportSelectionType(title: segmentRow?.value)
        switch type {
        case .keystore:
            keystoreRow?.value = string
            keystoreRow?.reload()
        case .privateKey:
            privateKeyRow?.value = string
            privateKeyRow?.reload()
        case .address:
            guard let result = QRURLParser.from(string: string) else { return }
            addressRow?.value = result.address
            addressRow?.reload()
        case .mnemonic:
            phraseRow?.value = string
            phraseRow?.reload()
        }
    }

    @objc func pasteAddressAction() {
        let value = UIPasteboard.general.string?.trimmed
        addressRow?.value = value
        addressRow?.reload()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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

extension ImportWalletViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        setValueForCurrentField(string: result)
        reader.dismiss(animated: true)
    }
}

extension WalletInfo {
    static var emptyName: String {
        return "Unnamed " + R.string.localizable.wallet()
    }

    static func initialName(index numberOfWallets: Int) -> String {
        if numberOfWallets == 0 {
            return R.string.localizable.mainWallet()
        }
        return String(format: "%@ %@", R.string.localizable.wallet(), "\(numberOfWallets + 1)"
        )
    }
}
