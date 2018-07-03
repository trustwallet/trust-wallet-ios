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
    let transferType: TransferType
    let currencyRate: CurrencyRate?
    private let fullFormatter = EtherNumberFormatter.full

    struct Values {
        static let gasPrice = "gasPrice"
        static let gasLimit = "gasLimit"
        static let totalFee = "totalFee"
        static let data = "data"
        static let nonce = "nonce"
    }

    lazy var viewModel: ConfigureTransactionViewModel = {
        return ConfigureTransactionViewModel(
            config: self.config,
            transferType: self.transferType
        )
    }()

    private var gasPriceRow: SliderTextFieldRow? {
        return form.rowBy(tag: Values.gasPrice) as? SliderTextFieldRow
    }
    private var gasLimitRow: SliderTextFieldRow? {
        return form.rowBy(tag: Values.gasLimit) as? SliderTextFieldRow
    }
    private var totalFeeRow: TextRow? {
        return form.rowBy(tag: Values.totalFee) as? TextRow
    }
    private var dataRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.data) as? TextFloatLabelRow
    }
    private var nonceRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.nonce) as? TextFloatLabelRow
    }

    private var gasLimit: BigInt {
        return BigInt(String(Int(gasLimitRow?.value ?? 0)), radix: 10) ?? BigInt()
    }
    private var gasPrice: BigInt {
        return fullFormatter.number(from: String(Int(gasPriceRow?.value ?? 1)), units: UnitConfiguration.gasPriceUnit) ?? BigInt()
    }
    private var totalFee: BigInt {
        return gasPrice * gasLimit
    }
    private var dataString: String {
        return dataRow?.value ?? "0x"
    }
    private var nonce: BigInt {
        return BigInt(nonceRow?.value ?? "0") ?? 0
    }

    private var gasViewModel: GasViewModel {
        return GasViewModel(fee: totalFee, server: config.server, currencyRate: currencyRate, formatter: fullFormatter)
    }

    weak var delegate: ConfigureTransactionViewControllerDelegate?

    init(
        configuration: TransactionConfiguration,
        transferType: TransferType,
        config: Config,
        currencyRate: CurrencyRate?
    ) {
        self.configuration = configuration
        self.transferType = transferType
        self.config = config
        self.currencyRate = currencyRate

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let gasPriceGwei = EtherNumberFormatter.full.string(from: configuration.gasPrice, units: UnitConfiguration.gasPriceUnit)

        form = Section(
            footer: viewModel.gasPriceFooterText
        )

        <<< SliderTextFieldRow(Values.gasPrice) {
            $0.title = NSLocalizedString("configureTransaction.gasPriceGwei.label.title", value: "Gas Price (Gwei)", comment: "")
            $0.value = Float(gasPriceGwei) ?? 1
            $0.minimumValue = Float(GasPriceConfiguration.min / BigInt(UnitConfiguration.gasPriceUnit.rawValue))
            $0.maximumValue = Float(GasPriceConfiguration.max / BigInt(UnitConfiguration.gasPriceUnit.rawValue))
            $0.steps = UInt((GasPriceConfiguration.max / GasPriceConfiguration.min))
            $0.displayValueFor = { (rowValue: Float?) in
                return "\(Int(rowValue ?? 1))"
            }
            $0.onChange { [weak self] _ in
                self?.recalculateTotalFee()
            }
        }

        +++ Section(
            footer: viewModel.gasLimitFooterText
        )

        <<< SliderTextFieldRow(Values.gasLimit) {
            $0.title = NSLocalizedString("configureTransaction.gasLimit.label.title", value: "Gas Limit", comment: "")
            $0.value = Float(configuration.gasLimit.description) ?? 21000
            $0.minimumValue = Float(GasLimitConfiguration.min)
            $0.maximumValue = Float(GasLimitConfiguration.max)
            $0.steps = UInt((GasLimitConfiguration.max - GasLimitConfiguration.min) / 1000)
            $0.displayValueFor = { (rowValue: Float?) in
                return "\(Int(rowValue ?? 1))"
            }
            $0.onChange { [unowned self] _ in
                self.recalculateTotalFee()
            }
        }

        +++ Section()

        <<< AppFormAppearance.textFieldFloat(tag: Values.data) {
            let dataText = String(format:
                NSLocalizedString(
                    "configureTransaction.dataField.label.title",
                    value: "Data (Optional). %@",
                    comment: ""
            ), self.configuration.data.description)
            $0.title = dataText
            $0.value = self.configuration.data.hexEncoded
        }

        +++ Section()

        <<< AppFormAppearance.textFieldFloat(tag: Values.nonce) {
            $0.title = NSLocalizedString("Nonce", value: "Nonce", comment: "")
            $0.value = "\(self.configuration.nonce)"
        }.cellUpdate { cell, _ in
            cell.textField.keyboardType = .numberPad
        }

        +++ Section()

        <<< TextRow(Values.totalFee) {
            $0.title = NSLocalizedString("Network Fee", value: "Network Fee", comment: "")
            $0.disabled = true
        }

        recalculateTotalFee()
    }

    func recalculateTotalFee() {
        let feeAndSymbol = gasViewModel.feeText
        totalFeeRow?.value = feeAndSymbol
        totalFeeRow?.updateCell()
    }

    @objc func save() {
        guard gasLimit <= ConfigureTransaction.gasLimitMax else {
            return displayError(error: ConfigureTransactionError.gasLimitTooHigh)
        }

        guard totalFee <= ConfigureTransaction.gasFeeMax else {
            return displayError(error: ConfigureTransactionError.gasFeeTooHigh)
        }

        let data: Data = {
            if dataString.isEmpty {
                return Data()
            }
            return Data(hex: dataString.drop0x)
        }()

        let configuration = TransactionConfiguration(
            gasPrice: gasPrice,
            gasLimit: gasLimit,
            data: data,
            nonce: nonce
        )
        delegate?.didEdit(configuration: configuration, in: self)
    }
}
