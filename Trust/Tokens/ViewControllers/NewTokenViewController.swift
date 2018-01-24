// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Eureka
import TrustKeystore
import QRCodeReaderViewController

protocol NewTokenViewControllerDelegate: class {
    func didAddToken(token: ERC20Token, in viewController: NewTokenViewController)
}

class NewTokenViewController: FormViewController {

    let viewModel = NewTokenViewModel()

    private struct Values {
        static let contract = "contract"
        static let symbol = "symbol"
        static let decimals = "decimals"
    }

    weak var delegate: NewTokenViewControllerDelegate?

    private var contractRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.contract) as? TextFloatLabelRow
    }
    private var symbolRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.symbol) as? TextFloatLabelRow
    }
    private var decimalsRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.decimals) as? TextFloatLabelRow
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title

        let recipientRightView = FieldAppereance.addressFieldRightView(
            pasteAction: { self.pasteAction() },
            qrAction: { self.openReader() }
        )

        form = Section()

            +++ Section()

            <<< AppFormAppearance.textFieldFloat(tag: Values.contract) {
                $0.add(rule: EthereumAddressRule())
                $0.validationOptions = .validatesOnDemand
                $0.title = NSLocalizedString("Contract Address", value: "Contract Address", comment: "")
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.rightView = recipientRightView
                cell.textField.rightViewMode = .always
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.symbol) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                $0.title = NSLocalizedString("Symbol", value: "Symbol", comment: "")
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.decimals) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                $0.title = NSLocalizedString("Decimals", value: "Decimals", comment: "")
                $0.cell.textField.keyboardType = .decimalPad
            }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(addToken))
    }

    @objc func addToken() {
        guard form.validate().isEmpty else {
            return
        }

        let contract = contractRow?.value ?? ""
        let symbol = symbolRow?.value ?? ""
        let decimals = Int(decimalsRow?.value ?? "") ?? 0

        guard let address = Address(string: contract) else {
            return displayError(error: AddressError.invalidAddress)
        }

        let token = ERC20Token(
            contract: address,
            symbol: symbol,
            decimals: decimals
        )

        delegate?.didAddToken(token: token, in: self)
    }

    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self

        present(controller, animated: true, completion: nil)
    }

    @objc func pasteAction() {
        guard let value = UIPasteboard.general.string?.trimmed else {
            return displayError(error: SendInputErrors.emptyClipBoard)
        }

        guard CryptoAddressValidator.isValidAddress(value) else {
            return displayError(error: AddressError.invalidAddress)
        }

        updateContractValue(value: value)
    }

    private func updateContractValue(value: String) {
        contractRow?.value = value
        contractRow?.reload()
    }
}

extension NewTokenViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)

        guard let result = QRURLParser.from(string: result) else { return }
        updateContractValue(value: result.address)
    }
}
