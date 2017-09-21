// Copyright SIX DAY LLC, Inc. All rights reserved.

import Foundation
import UIKit
import Geth
import Eureka
import JSONRPCKit
import APIKit
import QRCodeReaderViewController

class SendViewController: FormViewController {
    
    private let viewModel = SendViewModel()
    private let keystore = EtherKeystore()
    
    struct Values {
        static let address = "address"
        static let amount = "amount"
    }
    
    let account: Account
    
    init(account: Account) {
        self.account = account
        
        super.init(nibName: nil, bundle: nil)
        
        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .done, target: self, action: #selector(send))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        view.backgroundColor = .white
        
        form = Section()
            
            +++ Section("")
            
            <<< AppFormAppearance.textFieldFloat(tag: Values.address) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, row in
                let button = UIButton(type: UIButtonType.infoLight)
                button.addTarget(self, action: #selector(self.openReader), for: .touchUpInside)
                
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "Ethereum address"
                cell.textField.rightView = button
                cell.textField.rightViewMode = .always
            }
        
            <<< AppFormAppearance.textFieldFloat(tag: Values.amount) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, row in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = "ETH Amount"
                cell.textField.keyboardType = .decimalPad
            }
    }
    
    func clear() {
        let addressRow = (form.rowBy(tag: Values.address) as? TextFloatLabelRow)
        let amountRow = (form.rowBy(tag: Values.amount) as? TextFloatLabelRow)
        
        addressRow?.value = ""
        addressRow?.reload()
        
        amountRow?.value = ""
        amountRow?.reload()
    }
    
    func send() {
        let errors = form.validate()
        guard errors.count == 0 else { return }
        
        let addressString = (form.rowBy(tag: Values.address) as? TextFloatLabelRow)?.value ?? ""
        let amountString = (form.rowBy(tag: Values.amount) as? TextFloatLabelRow)?.value ?? ""
        let address = Address(address: addressString)
        let amountDouble = Double(amountString) ?? 0
        let amount = Int64(Double(EthereumUnit.ether.rawValue) * amountDouble)
        
        confirm(message: "Confirm to send \(amountString) ETH to \(address.address) address") { result in
            switch result {
            case .success:
                self.sendPayment(to: address, amount: amount)
            case .failure: break
            }
        }
    }
    
    func sendPayment(to address: Address, amount: Int64) {
        let request = EtherServiceRequest(batch: BatchFactory().create(GetTransactionCountRequest(address: account.address)))
        Session.send(request) { [weak self] result in
            switch result {
            case .success(let count):
                NSLog("GetTransactionsCountRequest \(count) for account \(self?.account.address ?? "")")
                self?.sign(address: address, nonce: count, amount: amount)
            case .failure(let error):
                NSLog("GetTransactionsCountRequest error \(error)")
            }
        }
    }
    
    func sign(address: Address, nonce: Int64 = 0, amount: Int64) {
        let config = Config()
        let res = keystore.signTransaction(
            amount: GethNewBigInt(amount),
            account: account,
            address: address,
            nonce: nonce,
            chainID: GethNewBigInt(Int64(config.chainID))
        )
        
        let amountString = Int64(Double(EthereumUnit.ether.rawValue) / Double(amount))
        
        switch res {
        case .success(let data):
            let sendData = "0x" + data.hex
            let request = EtherServiceRequest(batch: BatchFactory().create(SendRawTransactionRequest(signedTransaction: sendData)))
            Session.send(request) { [weak self] result in
                switch result {
                case .success(let transactionID):
                    self?.displaySuccess(
                        title: "Sent \(amountString) to \(self?.account.address ?? "")",
                        message: "TransactionID: \(transactionID)"
                    )
                    self?.clear()
                case .failure(let error):
                    self?.displayError(error: error)
                }
            }
        case .failure(let error):
            displayError(error: error)
        }
    }
    
    @objc func openReader() {
        // Or by using the closure pattern
        
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
        
        NSLog("result \(result)")
        
        let address = result.substring(with: 9..<51)
        
        NSLog("address \(address)")
        
        let row = (form.rowBy(tag: Values.address) as? TextFloatLabelRow)!
        row.value = address
        row.reload()
    }
}

extension String {
    func index(from: Int) -> Index {
        return self.index(startIndex, offsetBy: from)
    }
    
    func substring(from: Int) -> String {
        let fromIndex = index(from: from)
        return substring(from: fromIndex)
    }
    
    func substring(to: Int) -> String {
        let toIndex = index(from: to)
        return substring(to: toIndex)
    }
    
    func substring(with r: Range<Int>) -> String {
        let startIndex = index(from: r.lowerBound)
        let endIndex = index(from: r.upperBound)
        return substring(with: startIndex..<endIndex)
    }
}

