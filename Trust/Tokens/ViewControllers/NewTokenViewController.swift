// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import Eureka
import TrustCore
import QRCodeReaderViewController
import PromiseKit

protocol NewTokenViewControllerDelegate: class {
    func didAddToken(token: ERC20Token, in viewController: NewTokenViewController)
}

final class NewTokenViewController: FormViewController {

    private var viewModel: NewTokenViewModel
    private struct Values {
        static let network = "network"
        static let contract = "contract"
        static let name = "name"
        static let symbol = "symbol"
        static let decimals = "decimals"
    }

    weak var delegate: NewTokenViewControllerDelegate?

    private var networkRow: PushRow<RPCServer>? {
        return form.rowBy(tag: Values.network) as? PushRow<RPCServer>
    }

    private var contractRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.contract) as? TextFloatLabelRow
    }
    private var nameRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.name) as? TextFloatLabelRow
    }
    private var symbolRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.symbol) as? TextFloatLabelRow
    }
    private var decimalsRow: TextFloatLabelRow? {
        return form.rowBy(tag: Values.decimals) as? TextFloatLabelRow
    }

    init(
        viewModel: NewTokenViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = viewModel.title

        let recipientRightView = AddressFieldView()
        recipientRightView.translatesAutoresizingMaskIntoConstraints = false
        recipientRightView.pasteButton.addTarget(self, action: #selector(pasteAction), for: .touchUpInside)
        recipientRightView.qrButton.addTarget(self, action: #selector(openReader), for: .touchUpInside)

        let section = Section()

        if viewModel.networkSelectorAvailable {
            section.append(networks())
        }
        form = section

        +++ Section()

        <<< AppFormAppearance.textFieldFloat(tag: Values.contract) { [unowned self] in
            $0.add(rule: EthereumAddressRule())
            $0.validationOptions = .validatesOnDemand
            $0.title = R.string.localizable.contractAddress()
            $0.value = self.viewModel.contract
        }.cellUpdate { cell, _ in
            cell.textField.textAlignment = .left
            cell.textField.rightView = recipientRightView
            cell.textField.rightViewMode = .always
        }

        <<< AppFormAppearance.textFieldFloat(tag: Values.name) { [unowned self] in
            $0.add(rule: RuleRequired())
            $0.validationOptions = .validatesOnDemand
            $0.title = R.string.localizable.name()
            $0.value = self.viewModel.name
        }

        <<< AppFormAppearance.textFieldFloat(tag: Values.symbol) { [unowned self] in
            $0.add(rule: RuleRequired())
            $0.validationOptions = .validatesOnDemand
            $0.title = R.string.localizable.symbol()
            $0.value = self.viewModel.symbol
        }

        <<< AppFormAppearance.textFieldFloat(tag: Values.decimals) { [unowned self] in
            $0.add(rule: RuleRequired())
            $0.add(rule: RuleMaxLength(maxLength: 32))
            $0.validationOptions = .validatesOnDemand
            $0.title = R.string.localizable.decimals()
            $0.cell.textField.keyboardType = .decimalPad
            $0.value = self.viewModel.decimals
        }

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(finish))
    }

    private func networks() -> PushRow<RPCServer> {
        return PushRow<RPCServer> {
            $0.tag = Values.network
            $0.title = R.string.localizable.network()
            $0.selectorTitle = R.string.localizable.network()
            $0.options = viewModel.networks
            $0.value = viewModel.network
            $0.displayValueFor = { value in
                return value?.name
            }
        }.onPresent { _, selectorController in
            selectorController.enableDeselection = false
        }}

    @objc func finish() {
        guard form.validate().isEmpty else {
            return
        }

        let contract = contractRow?.value ?? ""
        let name = nameRow?.value ?? ""
        let symbol = symbolRow?.value ?? ""
        let decimals = Int(decimalsRow?.value ?? "") ?? 0
        let coin = (networkRow?.value ?? RPCServer.main).coin

        guard let address = EthereumAddress(string: contract) else {
            return displayError(error: Errors.invalidAddress)
        }

        let token = ERC20Token(
            contract: address,
            name: name,
            symbol: symbol,
            decimals: decimals,
            coin: coin
        )
        delegate?.didAddToken(token: token, in: self)
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
            return displayError(error: Errors.invalidAddress)
        }

        updateContractValue(value: value)
    }

    private func updateContractValue(value: String) {
        contractRow?.value = value
        contractRow?.reload()
        fetchInfo(for: value)
    }

    private func fetchInfo(for contract: String) {
        displayLoading()
        firstly {
            viewModel.info(for: contract)
        }.done { [weak self] token in
            self?.nameRow?.value = token.name
            self?.decimalsRow?.value = token.decimals.description
            self?.symbolRow?.value = token.symbol
            self?.nameRow?.reload()
            self?.decimalsRow?.reload()
            self?.symbolRow?.reload()
        }.ensure { [weak self] in
            self?.hideLoading()
        }.catch {_ in
            //We could not find any info about this contract.This error is already logged in crashlytics.
        }

    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension NewTokenViewController: QRCodeReaderDelegate {
    func readerDidCancel(_ reader: QRCodeReaderViewController!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)
    }

    func reader(_ reader: QRCodeReaderViewController!, didScanResult result: String!) {
        reader.stopScanning()
        reader.dismiss(animated: true, completion: nil)

        guard let result = QRURLParser.from(string: result) else { return }
        updateContractValue(value: result.address)
    }
}
