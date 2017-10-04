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
                cell.textField.placeholder = "Ethereum address"
                cell.textField.rightView = button
                cell.textField.rightViewMode = .always
            }

            <<< AppFormAppearance.textFieldFloat(tag: Values.amount) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "ETH Amount"
                cell.textField.keyboardType = .decimalPad
            }

            +++ Section {
                $0.hidden = Eureka.Condition.function([Values.amount], { _ in
                    return self.amountRow?.value?.isEmpty ?? true
                })
            }

            <<< AppFormAppearance.button("Additional configuration") {
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
        let amountDouble = BDouble(floatLiteral: amountString.doubleValue) * BDouble(integerLiteral: EthereumUnit.ether.rawValue)
        let amount = GethBigInt.from(double: amountDouble)
        let speed = configuration.speed

        confirm(message: "Confirm to send \(amountString) \(transferType.symbol) to \(address.address) address") { result in
            switch result {
            case .success:
                self.sendPayment(to: address, amount: amount, speed: speed, amountString: amountString)
            case .failure: break
            }
        }
    }

    func sendPayment(to address: Address, amount: GethBigInt, speed: TransactionSpeed, amountString: String) {
        displayLoading()
        let request = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(address: account.address.address)))
        Session.send(request) { [weak self] result in
            guard let `self` = self else { return }
            self.hideLoading()
            switch result {
            case .success(let count):
                self.sign(address: address, nonce: count, amount: amount, speed: speed, amountString: amountString)
            case .failure(let error):
                self.displayError(error: error)
            }
        }
    }

    func sign(
        address: Address,
        nonce: Int64 = 0,
        amount: GethBigInt,
        speed: TransactionSpeed,
        amountString: String
    ) {
        let config = Config()
        let res = keystore.signTransaction(
            amount: amount,
            account: account,
            address: address,
            nonce: nonce,
            speed: speed,
            chainID: GethNewBigInt(Int64(config.chainID))
        )

        switch res {
        case .success(let data):
            let sendData = data.hexEncoded
            let request = EtherServiceRequest(batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: sendData)))
            Session.send(request) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let transactionID):
                    self.displaySuccess(
                        title: "Sent \(amountString) \(self.transferType.symbol) to \(self.account.address.address)",
                        message: "TransactionID: \(transactionID)"
                    )
                    self.clear()
                case .failure(let error):
                    self.displayError(error: error)
                }
            }
        case .failure(let error):
            displayError(error: error)
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

extension String {
    var doubleValue: Double {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.decimalSeparator = "."
        if let result = formatter.number(from: self) {
            return result.doubleValue
        } else {
            formatter.decimalSeparator = ","
            if let result = formatter.number(from: self) {
                return result.doubleValue
            }
        }
        return 0
    }
}
