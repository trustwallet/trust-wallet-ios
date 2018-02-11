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

    private var gasViewModel: GasViewModel {
        return GasViewModel(fee: totalFee, symbol: config.server.symbol, currencyRate: currencyRate, formatter: fullFormatter)
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

        form = Section()

        +++ Section(
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
            $0.onChange { [unowned self] _ in
                self.recalculateTotalFee()
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

        +++ Section {
            $0.hidden = Eureka.Condition.function([], { _ in
                return self.viewModel.isDataInputHidden
            })
        }
        <<< AppFormAppearance.textFieldFloat(tag: Values.data) {
            $0.title = NSLocalizedString("configureTransaction.data.label.title", value: "Transaction Data (Optional)", comment: "")
            $0.value = self.configuration.data.hexEncoded
        }

        +++ Section()

        <<< TextRow(Values.totalFee) {
            $0.title = NSLocalizedString("configureTransaction.totalNetworkFee.label.title", value: "Total network fee", comment: "")
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
            data: data
        )
        delegate?.didEdit(configuration: configuration, in: self)
    }
}
