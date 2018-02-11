// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import Result

class AddCustomNetworkViewController: FormViewController {

    let viewModel = AddCustomNetworkViewModel()

    private struct Values {
        static let chainID = "chainID"
        static let name = "name"
        static let symbol = "symbol"
        static let endpoint = "endpoint"
    }

    weak var delegate: NewTokenViewControllerDelegate?

    private var chainIDRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.chainID) as? TextFloatLabelRow
    }
    private var nameRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.name) as? TextFloatLabelRow
    }
    private var symbolRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.symbol) as? TextFloatLabelRow
    }
    private var endpointRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.endpoint) as? TextFloatLabelRow
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title
        form = Section()

            +++ Section()

            <<< AppFormAppearance.textFieldFloat(tag: Values.chainID) {
                $0.add(rule: EthereumAddressRule())
                $0.validationOptions = .validatesOnDemand
                $0.title = NSLocalizedString("Chain ID", value: "Chain ID", comment: "")
            }.cellUpdate { cell, _ in
                cell.textField.keyboardType = .decimalPad
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.name) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                $0.title = NSLocalizedString("Name", value: "Name", comment: "")
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.symbol) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                $0.title = NSLocalizedString("Symbol", value: "Symbol", comment: "")
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.endpoint) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
                $0.title = NSLocalizedString("Endpoint", value: "Endpoint", comment: "")
            }
    }

    func addNetwork(completion: @escaping(Result<CustomRPC, AnyError>) -> Void) {
        guard form.validate().isEmpty else {
            return
        }
        let chainID = Int(chainIDRow?.value ?? "0") ?? 0
        let name = nameRow?.value ?? ""
        let symbol = symbolRow?.value ?? ""
        let endpoint = endpointRow?.value ?? ""

        let customNetwork = CustomRPC(
            chainID: chainID,
            name: name,
            symbol: symbol,
            endpoint: endpoint
        )

        completion(.success(customNetwork))
    }
}
