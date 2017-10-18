// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Geth
import Eureka
import JSONRPCKit
import APIKit
import QRCodeReaderViewController

protocol SendViewControllerDelegate: class {
    func didPressConfiguration(in viewController: SendViewController)
    func didCreatePendingTransaction(_ transaction: SentTransaction, in viewController: SendViewController)
}

class SendViewController: FormViewController {

    private lazy var viewModel: SendViewModel = {
        return .init(transferType: self.transferType)
    }()
    private let keystore = EtherKeystore()
    weak var delegate: SendViewControllerDelegate?

    struct Values {
        static let address = "address"
        static let amount = "amount"
    }

    let account: Account
    let transferType: TransferType

    var addressRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.address) as? TextFloatLabelRow
    }
    var amountRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.amount) as? TextFloatLabelRow
    }

    var configuration = TransactionConfiguration()

    lazy var sendTransactionCoordinator = {
        return SendTransactionCoordinator(account: self.account)
    }()

    init(account: Account, transferType: TransferType = .ether) {
        self.account = account
        self.transferType = transferType

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        form = Section()
            +++ Section("")

            <<< AppFormAppearance.textFieldFloat(tag: Values.address) {
                $0.add(rule: EthereumAddressRule())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                let button = UIButton(type: .custom)
                button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
                button.setImage(R.image.qr_code_icon(), for: .normal)
                button.addTarget(self, action: #selector(self.openReader), for: .touchUpInside)

                cell.textField.textAlignment = .left
                cell.textField.placeholder = "\(self.viewModel.symbol) " + NSLocalizedString("Send.AddressPlaceholder", value: "Address", comment: "")
                cell.textField.rightView = button
                cell.textField.rightViewMode = .always
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.amount) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "\(self.viewModel.symbol) " + NSLocalizedString("Send.AmountPlaceholder", value: "Amount", comment: "")
                cell.textField.keyboardType = .decimalPad
            }

            +++ Section {
                $0.hidden = Eureka.Condition.function([Values.amount], { _ in
                    return self.amountRow?.value?.isEmpty ?? true
                })
            }

            <<< AppFormAppearance.button(NSLocalizedString("Send.AdditionalConfiguration", value: "Additional Configuration", comment: "")) {
                $0.title = $0.tag
            }.onCellSelection { [unowned self] (_, _) in
                self.delegate?.didPressConfiguration(in: self)
            }
    }

    override func insertAnimation(forSections sections: [Section]) -> UITableViewRowAnimation {
        return .none
    }

    override func deleteAnimation(forSections sections: [Section]) -> UITableViewRowAnimation {
        return .none
    }

    func clear() {
        let fields = [addressRow, amountRow]
        for field in fields {
            field?.value = ""
            field?.reload()
        }
    }

    func send() {
        let errors = form.validate()
        guard errors.isEmpty else { return }

        let addressString = addressRow?.value ?? ""
        let amountString = amountRow?.value ?? ""
        let address = Address(address: addressString)
        let value = amountString.doubleValue

        confirm(message: "Confirm to send \(amountString) \(transferType.symbol) to \(address.address) address") { [unowned self] result in
            guard case .success = result else { return }
            self.displayLoading()
            self.sendTransactionCoordinator.send(
                address: address,
                value: value,
                configuration: self.configuration
            ) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let transaction):
                    self.displaySuccess(
                        title: "Sent \(amountString) \(self.transferType.symbol) to \(self.account.address.address)",
                        message: "TransactionID: \(transaction.id)"
                    )
                    self.clear()
                case .failure(let error):
                    self.displayError(error: error)
                }
                self.hideLoading()
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

extension SendViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.dismiss(animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.dismiss(animated: true, completion: nil)

        //Move login into parser
        let address = result.substring(with: 9..<51)
        addressRow?.value = address
        addressRow?.reload()
    }
}
