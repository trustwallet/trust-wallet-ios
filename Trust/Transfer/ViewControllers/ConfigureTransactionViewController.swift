// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Eureka
import BigInt

protocol ConfigureTransactionViewControllerDelegate: class {
    func didEdit(configuration: TransactionConfiguration, in viewController: ConfigureTransactionViewController)
}

class ConfigureTransactionViewController: FormViewController {

    let configuration: TransactionConfiguration
    let config: Config

    struct Values {
        static let gasPrice = "gasPrice"
        static let gasLimit = "gasLimit"
    }

    lazy var viewModel: ConfigureTransactionViewModel = {
        return ConfigureTransactionViewModel(config: self.config)
    }()

    var gasPriceRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.gasPrice) as? TextFloatLabelRow
    }
    var gasLimitRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.gasLimit) as? TextFloatLabelRow
    }

    weak var delegate: ConfigureTransactionViewControllerDelegate?

    init(
        configuration: TransactionConfiguration,
        config: Config
    ) {
        self.configuration = configuration
        self.config = config

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: NSLocalizedString("generic.save", value: "Save", comment: ""), style: .done, target: self, action: #selector(self.save))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        form = Section()

        +++ Section(
            footer: viewModel.gasLimitFooterText
        )

        <<< AppFormAppearance.textFieldFloat(tag: Values.gasPrice) {
            $0.validationOptions = .validatesOnDemand
            $0.value = self.configuration.speed.gasPrice.description
        }.cellUpdate { cell, _ in
            cell.textField.textAlignment = .left
            cell.textField.placeholder = NSLocalizedString("configureTransaction.gasPrice", value: "Gas Price", comment: "")
            cell.textField.rightViewMode = .always
        }

        +++ Section(
            footer: viewModel.gasLimitFooterText
        )
        <<< AppFormAppearance.textFieldFloat(tag: Values.gasLimit) {
            $0.validationOptions = .validatesOnDemand
            $0.value = self.configuration.speed.gasLimit.description
        }.cellUpdate { cell, _ in
            cell.textField.textAlignment = .left
            cell.textField.placeholder = NSLocalizedString("configureTransaction.gasLimit", value: "Gas Limit", comment: "")
            cell.textField.rightViewMode = .always
        }
    }

    @objc func save() {
        let gasPrice = BigInt(gasPriceRow?.value ?? "0", radix: 10) ?? BigInt()
        let gasLimit = BigInt(gasLimitRow?.value ?? "0", radix: 10) ?? BigInt()
        let configuration = TransactionConfiguration(
            speed: .custom(
                gasPrice: gasPrice,
                gasLimit: gasLimit
            )
        )
        delegate?.didEdit(configuration: configuration, in: self)
    }
}
