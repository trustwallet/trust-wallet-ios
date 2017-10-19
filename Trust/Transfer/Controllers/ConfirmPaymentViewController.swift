// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StackViewController

protocol ConfirmPaymentViewControllerDelegate: class {
    func didCompleted(transaction: SentTransaction, in viewController: ConfirmPaymentViewController)
}

class ConfirmPaymentViewController: UIViewController {

    let transaction: UnconfirmedTransaction
    let account: Account
    let stackViewController = StackViewController()
    lazy var sendTransactionCoordinator = {
        return SendTransactionCoordinator(account: self.account)
    }()
    lazy var submitButton: UIButton = {
        let button = Button(size: .large, style: .squared)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(NSLocalizedString("confirmPayment.send", value: "Send", comment: ""), for: .normal)
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        return button
    }()
    weak var delegate: ConfirmPaymentViewControllerDelegate?
    let configuration = TransactionConfiguration()

    init(
        account: Account,
        transaction: UnconfirmedTransaction
    ) {
        self.account = account
        self.transaction = transaction

        super.init(nibName: nil, bundle: nil)

        view.backgroundColor = .white
        navigationItem.title = NSLocalizedString("confirmPayment.title", value: "Confirm", comment: "")

        let fee = EthereumConverter.from(value: BInt(configuration.speed.gasPrice.string()), to: .ether, minimumFractionDigits: 9)

        let items: [UIView] = [
            TransactionAppearance.spacer(),
            TransactionAppearance.header(
                viewModel: TransactionHeaderViewModel(
                    amount: transaction.amount,
                    direction: .outgoing
                )
            ),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            TransactionAppearance.item(title: NSLocalizedString("confirmPayment.from", value: "From", comment: ""), subTitle: account.address.address),
            TransactionAppearance.item(title: NSLocalizedString("confirmPayment.to", value: "To", comment: ""), subTitle: transaction.address.address),
            TransactionAppearance.item(title: NSLocalizedString("confirmPayment.fee", value: "Fee", comment: ""), subTitle: fee + " ETH"),
        ]

        for item in items {
            stackViewController.addItem(item)
        }

        stackViewController.scrollView.alwaysBounceVertical = true
        stackViewController.stackView.spacing = 10
        stackViewController.view.addSubview(submitButton)

        NSLayoutConstraint.activate([
            submitButton.bottomAnchor.constraint(equalTo: stackViewController.view.bottomAnchor),
            submitButton.trailingAnchor.constraint(equalTo: stackViewController.view.trailingAnchor),
            submitButton.leadingAnchor.constraint(equalTo: stackViewController.view.leadingAnchor),
        ])

        displayChildViewController(viewController: stackViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func send() {
        self.displayLoading()
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
    }
}
