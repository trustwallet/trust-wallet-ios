// Copyright DApps Platform Inc. All rights reserved.

import BigInt
import Foundation
import UIKit
import Result
import StatefulViewController

enum ConfirmType {
    case sign
    case signThenSend
}

enum ConfirmResult {
    case signedTransaction(SentTransaction)
    case sentTransaction(SentTransaction)
}

class ConfirmPaymentViewController: UIViewController {

    private let keystore: Keystore
    let session: WalletSession
    lazy var sendTransactionCoordinator = {
        return SendTransactionCoordinator(session: self.session, keystore: keystore, confirmType: confirmType, server: server)
    }()
    lazy var submitButton: UIButton = {
        let button = Button(size: .large, style: .solid)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(viewModel.actionButtonText, for: .normal)
        button.addTarget(self, action: #selector(send), for: .touchUpInside)
        return button
    }()
    lazy var viewModel: ConfirmPaymentViewModel = {
        //TODO: Refactor
        return ConfirmPaymentViewModel(type: self.confirmType)
    }()
    var configurator: TransactionConfigurator
    let confirmType: ConfirmType
    let server: RPCServer
    var didCompleted: ((Result<ConfirmResult, AnyError>) -> Void)?

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.spacing = 0
        stackView.axis = .vertical
        //stackView.alignment = .top
        //stackView.distribution
        return stackView
    }()

    lazy var footerStack: UIStackView = {
        let footerStack = UIStackView(arrangedSubviews: [
            submitButton,
        ])
        footerStack.translatesAutoresizingMaskIntoConstraints = false
        return footerStack
    }()

    init(
        session: WalletSession,
        keystore: Keystore,
        configurator: TransactionConfigurator,
        confirmType: ConfirmType,
        server: RPCServer
    ) {
        self.session = session
        self.keystore = keystore
        self.configurator = configurator
        self.confirmType = confirmType
        self.server = server

        super.init(nibName: nil, bundle: nil)

        navigationItem.rightBarButtonItem = UIBarButtonItem(image: R.image.transactionSlider(), style: .done, target: self, action: #selector(edit))
        view.backgroundColor = viewModel.backgroundColor
        navigationItem.title = viewModel.title

        errorView = ErrorView(onRetry: { [weak self] in
            self?.fetch()
        })
        loadingView = LoadingView()

        view.addSubview(stackView)
        view.addSubview(footerStack)
        fetch()
    }

    func fetch() {
        startLoading()
        configurator.load { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success:
                self.reloadView()
                self.endLoading()
            case .failure(let error):
                self.endLoading(animated: true, error: error, completion: nil)
            }
        }
        configurator.configurationUpdate.subscribe { [weak self] _ in
            guard let `self` = self else { return }
            self.reloadView()
        }
    }

    private func configure(for detailsViewModel: ConfirmPaymentDetailsViewModel) {
        stackView.removeAllArrangedSubviews()

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.layoutGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            footerStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -StyleLayout.sideMargin),
            footerStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: StyleLayout.sideMargin),
            footerStack.bottomAnchor.constraint(equalTo: view.layoutGuide.bottomAnchor, constant: -StyleLayout.sideMargin),

            submitButton.leadingAnchor.constraint(equalTo: footerStack.leadingAnchor),
            submitButton.trailingAnchor.constraint(equalTo: footerStack.leadingAnchor),
        ])

        let header = TransactionHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.configure(for: detailsViewModel.transactionHeaderViewModel)

        let items: [UIView] = [
            .spacer(height: TransactionAppearance.spacing),
            header,
            .spacer(height: 10),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            .spacer(height: TransactionAppearance.spacing),
            TransactionAppearance.item(
                title: detailsViewModel.paymentFromTitle,
                subTitle: session.account.address.description
            ),
            .spacer(height: TransactionAppearance.spacing),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            .spacer(height: TransactionAppearance.spacing),
            TransactionAppearance.item(
                title: detailsViewModel.requesterTitle,
                subTitle: detailsViewModel.requesterText
            ),
            .spacer(height: TransactionAppearance.spacing),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            .spacer(height: TransactionAppearance.spacing),
            networkFeeView(detailsViewModel),
            .spacer(height: TransactionAppearance.spacing),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            TransactionAppearance.oneLine(
                title: detailsViewModel.totalTitle,
                subTitle: detailsViewModel.totalText,
                titleStyle: .headingSemiBold,
                subTitleStyle: .paragraph,
                layoutMargins: UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15),
                backgroundColor: UIColor(hex: "faf9f9")
            ),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
        ]

        for item in items {
            stackView.addArrangedSubview(item)
        }

        updateSubmitButton()
    }

    private func networkFeeView(_ viewModel: ConfirmPaymentDetailsViewModel) -> UIView {
        return TransactionAppearance.oneLine(
            title: viewModel.estimatedFeeTitle,
            subTitle: viewModel.estimatedFeeText
        ) { [unowned self] _, _, _ in
            self.edit()
        }
    }

    private func updateSubmitButton() {
        let status = configurator.balanceValidStatus()
        let buttonTitle = viewModel.getActionButtonText(
            status, config: configurator.session.config,
            transfer: configurator.transaction.transfer
        )
        submitButton.isEnabled = status.sufficient
        submitButton.setTitle(buttonTitle, for: .normal)
    }

    private func reloadView() {
        let viewModel = ConfirmPaymentDetailsViewModel(
            transaction: configurator.previewTransaction(),
            currencyRate: session.balanceCoordinator.currencyRate,
            server: server
        )
        self.configure(for: viewModel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func edit() {
        let controller = ConfigureTransactionViewController(
            configuration: configurator.configuration,
            transfer: configurator.transaction.transfer,
            config: session.config,
            currencyRate: session.balanceCoordinator.currencyRate
        )
        controller.delegate = self
        self.navigationController?.pushViewController(controller, animated: true)
    }

    @objc func send() {
        self.displayLoading()

        let transaction = configurator.signTransaction
        self.sendTransactionCoordinator.send(transaction: transaction) { [weak self] result in
            guard let `self` = self else { return }
            self.didCompleted?(result)
            self.hideLoading()
        }
    }
}

extension ConfirmPaymentViewController: StatefulViewController {
    func hasContent() -> Bool {
        return true
    }
}

extension ConfirmPaymentViewController: ConfigureTransactionViewControllerDelegate {
    func didEdit(configuration: TransactionConfiguration, in viewController: ConfigureTransactionViewController) {
        configurator.update(configuration: configuration)
        reloadView()
        navigationController?.popViewController(animated: true)
    }
}
