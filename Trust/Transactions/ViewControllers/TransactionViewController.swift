// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StackViewController
import Result
import SafariServices

class TransactionViewController: UIViewController {

    private lazy var viewModel: TransactionViewModel = {
        return .init(
            transaction: self.transaction,
            config: self.config,
            chainState: self.session.chainState
        )
    }()
    let stackViewController = StackViewController()

    let session: WalletSession
    let transaction: Transaction
    let config = Config()

    init(
        session: WalletSession,
        transaction: Transaction
    ) {
        self.session = session
        self.transaction = transaction

        stackViewController.scrollView.alwaysBounceVertical = true
        stackViewController.stackView.spacing = 10

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        let items: [UIView] = [
            .spacer(),
            TransactionAppearance.header(
                viewModel: TransactionHeaderViewModel(
                    value: viewModel.value,
                    direction: transaction.direction
                )
            ),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            item(title: "From", value: viewModel.from),
            item(title: "To", value: viewModel.to),
            item(title: "Gas Fee", value: viewModel.gasFee),
            item(title: "Confirmation", value: viewModel.confirmation),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            item(title: "Transaction #", value: viewModel.transactionID),
            item(title: "Transaction time", value: viewModel.createdAt),
            item(title: "Block #", value: viewModel.blockNumber),
            moreDetails(),
        ]

        for item in items {
            stackViewController.addItem(item)
        }

        displayChildViewController(viewController: stackViewController)
    }

    private func item(title: String, value: String) -> UIView {
        return TransactionAppearance.item(
            title: title,
            subTitle: value
        ) { [weak self] in
            self?.showAlertSheet(title: $0, value: $1)
        }
    }

    private func moreDetails() -> UIView {
        let button = Button(size: .large, style: .border)
        button.setTitle("More Details", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(more), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [button])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        stackView.isLayoutMarginsRelativeArrangement = true

        return stackView
    }

    func showAlertSheet(title: String, value: String) {
        let alertController = UIAlertController(
            title: nil,
            message: value,
            preferredStyle: .actionSheet
        )
        alertController.popoverPresentationController?.sourceView = self.view
        let copyAction = UIAlertAction(title: NSLocalizedString("transactionDetails.copy", value: "Copy", comment: ""), style: .default) { _ in
            UIPasteboard.general.string = value
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("generic.cancel", value: "Cancel", comment: ""), style: .cancel) { _ in }
        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc func more() {
        let controller = SFSafariViewController(url: viewModel.detailsURL)
        present(controller, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
