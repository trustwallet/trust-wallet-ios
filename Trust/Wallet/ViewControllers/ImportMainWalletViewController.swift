// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import Eureka
import QRCodeReaderViewController
import TrustCore

protocol ImportMainWalletViewControllerDelegate: class {
    func didImportWallet(wallet: WalletInfo, in controller: ImportMainWalletViewController)
}

final class ImportMainWalletViewController: FormViewController {

    let keystore: Keystore

    struct Values {
        static let mnemonic = "mnemonic"
        static let password = "password"
    }

    var mnemonicRow: TextAreaRow? {
        return form.rowBy(tag: Values.mnemonic)
    }
    var passwordRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.password)
    }
    weak var delegate: ImportMainWalletViewControllerDelegate?

    init(
        keystore: Keystore
    ) {
        self.keystore = keystore
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("ImportMainWallet", value: "Import Main Wallet", comment: "")
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(image: R.image.qr_code_icon(), style: .done, target: self, action: #selector(openReader)),
        ]

        form
            +++ Section()

            // Mnemonic
            +++ Section(footer: ImportSelectionType.mnemonic.footerTitle)
            <<< AppFormAppearance.textArea(tag: Values.mnemonic) {
                $0.placeholder = R.string.localizable.importWalletMnemonicPlaceholder()
                $0.textAreaHeight = .fixed(cellHeight: 140)
                $0.add(rule: RuleRequired())
                $0.cell.textView?.autocapitalizationType = .none
            }

            +++ Section()
            <<< ButtonRow(R.string.localizable.importWalletImportButtonTitle()) {
                $0.title = $0.tag
            }.onCellSelection { [weak self] _, _ in
                self?.importWallet()
            }
    }

    func didImport(account: WalletInfo) {
        delegate?.didImportWallet(wallet: account, in: self)
    }

    func importWallet() {
        let validatedError = mnemonicRow?.section?.form?.validate()
        guard let errors = validatedError, errors.isEmpty else { return }

        let password = passwordRow?.value ?? ""
        let mnemonicInput = mnemonicRow?.value?.trimmed ?? ""
        let words = mnemonicInput.components(separatedBy: " ").map { $0.trimmed.lowercased() }

        displayLoading(text: R.string.localizable.importWalletImportingIndicatorLabelTitle(), animated: false)

        let importType = ImportType.mnemonic(words: words, password: password, derivationPath: Coin.ethereum.derivationPath(at: 0))

        keystore.importWallet(type: importType, coin: .ethereum) { result in
            self.hideLoading(animated: false)
            switch result {
            case .success(let account):
                self.didImport(account: account)
            case .failure(let error):
                self.displayError(error: error)
            }
        }
    }

    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self
        present(controller, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ImportMainWalletViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }
    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()

        mnemonicRow?.value = result
        mnemonicRow?.reload()

        reader.dismiss(animated: true)
    }
}
