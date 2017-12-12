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
    private let fullFormatter = EtherNumberFormatter.full

    struct Values {
        static let gasPrice = "gasPrice"
        static let gasLimit = "gasLimit"
        static let totalFee = "totalFee"
    }

    private struct Constant {
        static let minGasPrice: Float = 1
        static let maxGasPrice: Float = 120
        static let gasPriceSteps: UInt = 120

        static let minGasLimit: Float = 21000
        static let maxGasLimit: Float = 300000
        static let gasLimitSteps: UInt = 60
    }

    lazy var viewModel: ConfigureTransactionViewModel = {
        return ConfigureTransactionViewModel(config: self.config)
    }()

    private var gasPriceRow: SliderRow? {
        return form.rowBy(tag: Values.gasPrice) as? SliderRow
    }
    private var gasLimitRow: SliderRow? {
        return form.rowBy(tag: Values.gasLimit) as? SliderRow
    }
    private var totalFeeRow: TextRow? {
        return form.rowBy(tag: Values.totalFee) as? TextRow
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

    weak var delegate: ConfigureTransactionViewControllerDelegate?

    init(
        configuration: TransactionConfiguration,
        config: Config
    ) {
        self.configuration = configuration
        self.config = config

        super.init(nibName: nil, bundle: nil)

        navigationItem.title = viewModel.title
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save))
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let gasPriceGwei = EtherNumberFormatter.full.string(from: configuration.speed.gasPrice, units: UnitConfiguration.gasPriceUnit)

        form = Section()

        +++ Section(
            footer: viewModel.gasPriceFooterText
        )

        <<< SliderRow(Values.gasPrice) {
            $0.title = NSLocalizedString("configureTransaction.gasPrice.label.title", value: "Gas Price", comment: "")
            $0.value = Float(gasPriceGwei) ?? 1
            $0.minimumValue = Constant.minGasPrice
            $0.maximumValue = Constant.maxGasPrice
            $0.steps = Constant.gasPriceSteps
            $0.displayValueFor = { (rowValue: Float?) in
                return "\(Int(rowValue ?? 1)) (Gwei)"
            }
            $0.onChange { [unowned self] _ in
                self.recalculateTotalFee()
            }
        }

        +++ Section(
            footer: viewModel.gasLimitFooterText
        )

        <<< SliderRow(Values.gasLimit) {
            $0.title = NSLocalizedString("configureTransaction.gasLimit.label.title", value: "Gas Limit", comment: "")
            $0.value = Float(configuration.speed.gasLimit.description) ?? 21000
            $0.minimumValue = Constant.minGasLimit
            $0.maximumValue = Constant.maxGasLimit
            $0.steps = Constant.gasLimitSteps
            $0.displayValueFor = { (rowValue: Float?) in
                return "\(Int(rowValue ?? 1))"
            }
            $0.onChange { [unowned self] _ in
                self.recalculateTotalFee()
            }
        }

        +++ Section()

        <<< TextRow(Values.totalFee) {
            $0.title = NSLocalizedString("configureTransaction.totalNetworkFee.label.title", value: "Total network fee", comment: "")
            $0.disabled = true
        }

        recalculateTotalFee()
    }

    func recalculateTotalFee() {
        totalFeeRow?.value = "\(fullFormatter.string(from: totalFee)) \(config.server.symbol)"
        totalFeeRow?.updateCell()
    }

    @objc func save() {
        guard gasLimit <= ConfigureTransaction.gasLimitMax else {
            return displayError(error: ConfigureTransactionError.gasLimitTooHigh)
        }

        guard totalFee <= ConfigureTransaction.gasFeeMax else {
            return displayError(error: ConfigureTransactionError.gasFeeTooHigh)
        }

        let configuration = TransactionConfiguration(
            speed: .custom(
                gasPrice: gasPrice,
                gasLimit: gasLimit
            )
        )
        delegate?.didEdit(configuration: configuration, in: self)
    }
}
