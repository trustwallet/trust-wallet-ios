// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StackViewController
import Geth

protocol ConfirmPaymentViewControllerDelegate: class {
    func didCompleted(transaction: SentTransaction, in viewController: ConfirmPaymentViewController)
}

class ConfirmPaymentViewController: UIViewController {

    let transaction: UnconfirmedTransaction
    let session: WalletSession
    let transferType: TransferType
    let stackViewController = StackViewController()
    lazy var sendTransactionCoordinator = {
        return SendTransactionCoordinator(session: self.session)
    }()
    lazy var submitButton: UIButton = {
        let button = Button(size: .large, style: .solid)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("confirmPayment.send", value: "Send", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        return button
    }()
    weak var delegate: ConfirmPaymentViewControllerDelegate?

    lazy var configuration: TransactionConfiguration = {
        switch self.transferType {
        case .token:
            return TransactionConfiguration(
                speed: TransactionSpeed.custom(
                    gasPrice: TransactionSpeed.cheap.gasPrice,
                    gasLimit: GethNewBigInt(144000)
                )
            )
        case .ether:
            return TransactionConfiguration()
        }
    }()

    init(
        session: WalletSession,
        transaction: UnconfirmedTransaction,
        transferType: TransferType
    ) {
        self.session = session
        self.transaction = transaction
        self.transferType = transferType

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .white
        stackViewController.view.backgroundColor = .white

        navigationItem.title = NSLocalizedString("confirmPayment.title", value: "Confirm", comment: "")

        let totalFee = BInt(configuration.speed.gasPrice.string()) * BInt(configuration.speed.gasLimit.string())
        let fee = EthereumConverter.from(value: totalFee, to: .ether, minimumFractionDigits: 6)

        let items: [UIView] = [
            .spacer(),
            TransactionAppearance.header(
                viewModel: ConfirmTransactionHeaderViewModel(
                    transaction: transaction
                )
            ),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            TransactionAppearance.item(title: NSLocalizedString("confirmPayment.from", value: "From", comment: ""), subTitle: session.account.address.address),
            TransactionAppearance.item(title: NSLocalizedString("confirmPayment.to", value: "To", comment: ""), subTitle: transaction.address.address),
            TransactionAppearance.item(title: NSLocalizedString("confirmPayment.gasFee", value: "Gas Fee", comment: ""), subTitle: fee + " ETH"),
        ]

        for item in items {
            stackViewController.addItem(item)
        }

        stackViewController.scrollView.alwaysBounceVertical = true
        stackViewController.stackView.spacing = 10
        stackViewController.view.addSubview(submitButton)

        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: stackViewController.view.layoutGuide.bottomAnchor, constant: -15),
            submitButton.trailingAnchor.constraint(equalTo: stackViewController.view.trailingAnchor, constant: -15),
            submitButton.leadingAnchor.constraint(equalTo: stackViewController.view.leadingAnchor, constant: 15),
        ])

        displayChildViewController(viewController: stackViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func send() {
        self.displayLoading()

        switch transferType {
        case .ether:
            self.sendTransactionCoordinator.send(
                address: transaction.address,
                value: transaction.amount,
                configuration: self.configuration
            ) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let transaction):
                    self.delegate?.didCompleted(transaction: transaction, in: self)
                case .failure(let error):
                    self.displayError(error: error)
                }
                self.hideLoading()
            }
        case .token(let token):
            self.sendTransactionCoordinator.send(
                contract: token.address,
                to: transaction.address,
                amount: transaction.amount,
                decimals: token.decimals,
                configuration: self.configuration
            ) { [weak self] result in
                guard let `self` = self else { return }
                switch result {
                case .success(let transaction):
                    self.delegate?.didCompleted(transaction: transaction, in: self)
                case .failure(let error):
                    self.displayError(error: error)
                }
                self.hideLoading()
            }
        }
    }
}
