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

        let qrButton = UIButton(type: .custom)
        qrButton.translatesAutoresizingMaskIntoConstraints = false
        qrButton.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
        qrButton.setImage(R.image.qr_code_icon(), for: .normal)
        qrButton.addTarget(self, action: #selector(openReader), for: .touchUpInside)

        let recipientRightView = UIStackView(arrangedSubviews: [
            qrButton,
            .spacerWidth(1),
        ])
        recipientRightView.translatesAutoresizingMaskIntoConstraints = false
        recipientRightView.distribution = .equalSpacing
        recipientRightView.spacing = 10
        recipientRightView.axis = .horizontal

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

        let token = ERC20Token(
            contract: Address(string: contract),
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
}

extension NewTokenViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.dismiss(animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.dismiss(animated: true, completion: nil)

        guard let result = QRURLParser.from(string: result) else { return }
        contractRow?.value = result.address
        contractRow?.reload()
    }
}
