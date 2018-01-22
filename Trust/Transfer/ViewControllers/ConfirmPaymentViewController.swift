// Copyright SIX DAY LLC. All rights reserved.

import BigInt
import Foundation
import UIKit
import StackViewController

protocol ConfirmPaymentViewControllerDelegate: class {
    func didCompleted(transaction: SentTransaction, in viewController: ConfirmPaymentViewController)
}

class ConfirmPaymentViewController: UIViewController {

    private let keystore: Keystore
    //let transaction: UnconfirmedTransaction
    let session: WalletSession
    let stackViewController = StackViewController()
    lazy var sendTransactionCoordinator = {
        return SendTransactionCoordinator(session: self.session, keystore: keystore)
    }()
    lazy var submitButton: UIButton = {
        let button = Button(size: .large, style: .solid)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(viewModel.sendButtonText, for: .normal)
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        return button
    }()
    weak var delegate: ConfirmPaymentViewControllerDelegate?
    let viewModel = ConfirmPaymentViewModel()
    var configurator: TransactionConfigurator

    var didCompleted: ((_ transaction: SentTransaction) -> Void)?

    init(
        session: WalletSession,
        keystore: Keystore,
        configurator: TransactionConfigurator
    ) {
        self.session = session
        self.keystore = keystore
        self.configurator = configurator

        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.settings_icon(), style: .plain, target: self, action: #selector(edit))
        view.backgroundColor = viewModel.backgroundColor
        stackViewController.view.backgroundColor = viewModel.backgroundColor
        navigationItem.title = viewModel.title

        configurator.load { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success:
                self.reloadView()
            case .failure(let error):
                self.displayError(error: error)
            }
        }
        configurator.configurationUpdate.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            self.reloadView()
        }
    }

    func configure(for detailsViewModel: ConfirmPaymentDetailsViewModel) {
        stackViewController.items.forEach { stackViewController.removeItem($0) }

        let header = TransactionHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.amountLabel.attributedText = detailsViewModel.amountAttributedString

        let items: [UIView] = [
            .spacer(),
            header,
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            TransactionAppearance.item(
                title: detailsViewModel.paymentFromTitle,
                subTitle: session.account.address.description
            ),
            TransactionAppearance.item(
                title: detailsViewModel.paymentToTitle,
                subTitle: detailsViewModel.paymentToText
            ),
            TransactionAppearance.item(
                title: detailsViewModel.gasLimitTitle,
                subTitle: detailsViewModel.gasLimitText
            ) { [unowned self] _, _, _ in
                self.edit()
            },
            TransactionAppearance.item(
                title: detailsViewModel.gasPriceTitle,
                subTitle: detailsViewModel.gasPriceText
            ) { [unowned self] _, _, _ in
                self.edit()
            },
            TransactionAppearance.item(
                title: detailsViewModel.feeTitle,
                subTitle: detailsViewModel.feeText
            ) { [unowned self] _, _, _ in
                self.edit()
            },
            TransactionAppearance.item(
                title: detailsViewModel.dataTitle,
                subTitle: detailsViewModel.dataText
            ) { [unowned self] _, _, _ in
                self.edit()
            },
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

    private func reloadView() {
        let viewModel = ConfirmPaymentDetailsViewModel(
            transaction: configurator.previewTransaction(),
            currentBalance: self.session.balance
        )
        self.configure(for: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func edit() {
        let controller = ConfigureTransactionViewController(
            configuration: configurator.configuration,
            transferType: configurator.transaction.transferType,
            config: session.config
        )
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @objc func send() {
        self.displayLoading()

        let transaction = configurator.signTransaction()
        self.sendTransactionCoordinator.send(transactions: [transaction]) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let transaction):
                self.delegate?.didCompleted(transaction: transaction, in: self)
                self.didCompleted?(transaction)
            case .failure(let error):
                self.displayError(error: error)
            }
            self.hideLoading()
        }
    }
}

extension ConfirmPaymentViewController: ConfigureTransactionViewControllerDelegate {
    func didEdit(configuration: TransactionConfiguration, in viewController: ConfigureTransactionViewController) {
        configurator.update(configuration: configuration)
        reloadView()
        navigationController?.popViewController(animated: true)
    }
}
