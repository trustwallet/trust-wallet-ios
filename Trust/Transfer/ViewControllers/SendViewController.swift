// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Eureka
import JSONRPCKit
import APIKit
import QRCodeReaderViewController
import BigInt
import TrustKeystore

protocol SendViewControllerDelegate: class {
    func didPressConfirm(
        transaction: UnconfirmedTransaction,
        transferType: TransferType,
        in viewController: SendViewController
    )
}

class SendViewController: FormViewController {

    private lazy var viewModel: SendViewModel = {
        return .init(transferType: self.transferType, config: Config())
    }()
    weak var delegate: SendViewControllerDelegate?

    struct Values {
        static let address = "address"
        static let amount = "amount"
    }

    struct Pair {
        let left: String
        let right: String

        func swapPair() -> Pair {
            return Pair(left: right, right: left)
        }
    }

    var pairValue = 0.0
    let session: WalletSession
    let account: Account
    let transferType: TransferType
    let storage: TokensDataStore

    var addressRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.address) as? TextFloatLabelRow
    }
    var amountRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.amount) as? TextFloatLabelRow
    }

    private var gasPrice: BigInt?
    private var data = Data()

    lazy var currentPair: Pair = {
        return Pair(left: viewModel.symbol, right: session.config.currency.rawValue)
    }()

    init(
        session: WalletSession,
        storage: TokensDataStore,
        account: Account,
        transferType: TransferType = .ether(destination: .none)
    ) {
        self.session = session
        self.account = account
        self.transferType = transferType
        self.storage = storage

        super.init(nibName: nil, bundle: nil)

        storage.updatePrices()
        getGasPrice()

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        let recipientRightView = FieldAppereance.addressFieldRightView(
            pasteAction: { self.pasteAction() },
            qrAction: { self.openReader() }
        )

        let maxButton = Button(size: .normal, style: .borderless)
        maxButton.translatesAutoresizingMaskIntoConstraints = false
        maxButton.setTitle(NSLocalizedString("send.max.button.title", value: "Max", comment: ""), for: .normal)
        maxButton.addTarget(self, action: #selector(useMaxAmount), for: .touchUpInside)

        let fiatButton = Button(size: .normal, style: .borderless)
        fiatButton.translatesAutoresizingMaskIntoConstraints = false
        fiatButton.setTitle(currentPair.right, for: .normal)
        fiatButton.addTarget(self, action: #selector(fiatAction), for: .touchUpInside)
        fiatButton.isHidden = isFiatViewHidden()

        let amountRightView = UIStackView(arrangedSubviews: [
            fiatButton,
        ])

        amountRightView.translatesAutoresizingMaskIntoConstraints = false
        amountRightView.distribution = .equalSpacing
        amountRightView.spacing = 1
        amountRightView.axis = .horizontal

        form = Section()
            +++ Section(header: "", footer: isFiatViewHidden() ? "" : "~ \(String(self.pairValue)) " + "\(currentPair.right)")
            <<< AppFormAppearance.textFieldFloat(tag: Values.address) {
                $0.add(rule: EthereumAddressRule())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate { cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.placeholder = NSLocalizedString("send.recipientAddress.textField.placeholder", value: "Recipient Address", comment: "")
                cell.textField.rightView = recipientRightView
                cell.textField.rightViewMode = .always
                cell.textField.accessibilityIdentifier = "amount-field"
            }
            <<< AppFormAppearance.textFieldFloat(tag: Values.amount) {
                $0.add(rule: RuleRequired())
                $0.validationOptions = .validatesOnDemand
            }.cellUpdate {[weak self] cell, _ in
                cell.textField.textAlignment = .left
                cell.textField.delegate = self
                cell.textField.placeholder = "\(self?.currentPair.left ?? "") " + NSLocalizedString("send.amount.textField.placeholder", value: "Amount", comment: "")
                cell.textField.keyboardType = .decimalPad
                cell.textField.rightView = amountRightView
                cell.textField.rightViewMode = .always
            }
    }

    func getGasPrice() {
        let request = EtherServiceRequest(batch: BatchFactory().create(GasPriceRequest()))
        Session.send(request) { [weak self] result in
            switch result {
            case .success(let balance):
                self?.gasPrice = BigInt(balance.drop0x, radix: 16)
            case .failure: break
            }
        }
    }

    func clear() {
        let fields = [addressRow, amountRow]
        for field in fields {
            field?.value = ""
            field?.reload()
        }
    }

    @objc func send() {
        let errors = form.validate()
        guard errors.isEmpty else { return }

        let addressString = addressRow?.value?.trimmed ?? ""
        var amountString = ""
        if self.currentPair.left == viewModel.symbol {
            amountString = amountRow?.value?.trimmed ?? ""
        } else {
            amountString = String(pairValue).trimmed
        }

        guard let address = Address(string: addressString) else {
            return displayError(error: AddressError.invalidAddress)
        }

        let parsedValue: BigInt? = {
            switch transferType {
            case .ether: // exchange doesn't really matter here
                return EtherNumberFormatter.full.number(from: amountString, units: .ether)
            case .token(let token):
                return EtherNumberFormatter.full.number(from: amountString, decimals: token.decimals)
            }
        }()

        guard let value = parsedValue else {
            return displayError(error: SendInputErrors.wrongInput)
        }

        let transaction = UnconfirmedTransaction(
            transferType: transferType,
            value: value,
            to: address,
            data: data,
            gasLimit: .none,
            gasPrice: gasPrice,
            nonce: .none
        )
        self.delegate?.didPressConfirm(transaction: transaction, transferType: transferType, in: self)
    }

    @objc func openReader() {
        let controller = QRCodeReaderViewController()
        controller.delegate = self

        present(controller, animated: true, completion: nil)
    }

    @objc func pasteAction() {
        guard let value = UIPasteboard.general.string?.trimmed else {
            return displayError(error: SendInputErrors.emptyClipBoard)
        }

        guard CryptoAddressValidator.isValidAddress(value) else {
            return displayError(error: AddressError.invalidAddress)
        }

        addressRow?.value = value
        addressRow?.reload()

        activateAmountView()
    }

    @objc func useMaxAmount() {
        guard let value = session.balance?.amountFull else { return }

        amountRow?.value = value
        amountRow?.reload()
    }

    @objc func fiatAction(sender: UIButton) {
        let swappedPair = currentPair.swapPair()
        //New pair for future calculation we should swap pair each time we press fiat button.
        self.currentPair = swappedPair
        //Update button title.
        sender.setTitle(currentPair.right, for: .normal)
        //Reset amountRow value.
        amountRow?.value = nil
        amountRow?.reload()
        //Reset pair value.
        pairValue = 0.0
        //Update section.
        updatePriceSection()
        //Set focuse on pair change.
        activateAmountView()
    }

    func activateAmountView() {
        amountRow?.cell.textField.becomeFirstResponder()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func updatePriceSection() {
        //Update section only if fiat view is visible.
        guard !isFiatViewHidden() else {
            return
        }
        //We use this section update to prevent update of the all section including cells.
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        if let containerView = tableView.footerView(forSection: 1) {
            containerView.textLabel!.text = "~ \(String(self.pairValue)) " + "\(currentPair.right)"
            containerView.sizeToFit()
        }
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
    }

    private func updatePairPrice(with amount: Double) {
        guard let rates = storage.tickers, let currentTokenInfo = rates[viewModel.contract], let price = Double(currentTokenInfo.price) else {
            return
        }
        if self.currentPair.left == viewModel.symbol {
            pairValue = amount * price
        } else {
            pairValue = amount / price
        }
        self.updatePriceSection()
    }

    private func isFiatViewHidden() -> Bool {
        guard let rates = storage.tickers, let currentTokenInfo = rates[viewModel.contract], let _ = Double(currentTokenInfo.price) else {
            return true
        }
        return false
    }
}

extension SendViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.dismiss(animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.dismiss(animated: true, completion: nil)

        guard let result = QRURLParser.from(string: result) else { return }
        addressRow?.value = result.address
        addressRow?.reload()

        if let dataString = result.params["data"] {
            data = Data(hex: dataString.drop0x)
        } else {
            data = Data()
        }

        if let value = result.params["amount"] {
            amountRow?.value = EtherNumberFormatter.full.string(from: BigInt(value) ?? BigInt(), units: .ether)
        } else {
            amountRow?.value = ""
        }
        amountRow?.reload()

        activateAmountView()
    }
}

extension SendViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let text = (textField.text as NSString?)?.replacingCharacters(in: range, with: string)
        guard let total = text, let amount = Double(total) else {
            //Should be done in another way.
            pairValue = 0.0
            updatePriceSection()
            return true
        }
        self.updatePairPrice(with: amount)
        return true
    }
}
