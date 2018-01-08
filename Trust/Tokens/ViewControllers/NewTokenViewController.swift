// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import Eureka
import TrustKeystore

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

        form = Section()

            +++ Section()

            <<< AppFormAppearance.textFieldFloat(tag: Values.contract) {
                $0.add(rule: EthereumAddressRule())
                $0.validationOptions = .validatesOnDemand
                $0.title = NSLocalizedString("Contract Address", value: "Contract Address", comment: "")
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
}
