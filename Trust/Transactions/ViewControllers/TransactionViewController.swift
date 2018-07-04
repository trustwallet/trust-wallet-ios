// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StackViewController
import Result
import SafariServices

protocol TransactionViewControllerDelegate: class {
    func didPressURL(_ url: URL)
}

class TransactionViewController: UIViewController {

    private lazy var viewModel: TransactionDetailsViewModel = {
        return .init(
            transaction: self.transaction,
            config: self.config,
            chainState: self.session.chainState,
            currentWallet: self.session.account.wallet,
            currencyRate: self.session.balanceCoordinator.currencyRate
        )
    }()
    let stackViewController = StackViewController()

    let session: WalletSession
    let transaction: Transaction
    let config = Config()
    weak var delegate: TransactionViewControllerDelegate?

    init(
        session: WalletSession,
        transaction: Transaction
    ) {
        self.session = session
        self.transaction = transaction

        stackViewController.scrollView.alwaysBounceVertical = true
        stackViewController.stackView.spacing = TransactionAppearance.spacing

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        let header = TransactionHeaderView()
        header.translatesAutoresizingMaskIntoConstraints = false
        header.configure(for: viewModel.transactionHeaderViewModel)

        let dividerColor = Colors.whisper
        let dividerOffset = UIEdgeInsets(top: 0, left: 26, bottom: 0, right: 26)

        let confirmationView = item(title: viewModel.confirmationLabelTitle, value: viewModel.confirmation)
        confirmationView.widthAnchor.constraint(equalToConstant: 140).isActive = true

        var items: [UIView] = [
            .spacer(),
            header,
            TransactionAppearance.divider(color: dividerColor, alpha: 1, layoutInsets: dividerOffset),
            item(title: viewModel.addressTitle, value: viewModel.address),
            TransactionAppearance.divider(color: dividerColor, alpha: 1, layoutInsets: dividerOffset),
            item(
                title: viewModel.transactionIDLabelTitle,
                value: viewModel.transactionID,
                subTitleMinimumScaleFactor: 1
            ),
            TransactionAppearance.divider(color: dividerColor, alpha: 1, layoutInsets: dividerOffset),
            item(title: viewModel.gasFeeLabelTitle, value: viewModel.gasFee),
            TransactionAppearance.divider(color: dividerColor, alpha: 1),
            TransactionAppearance.horizontalItem(views: [
                confirmationView,
                TransactionAppearance.divider(direction: .vertical, color: dividerColor, alpha: 1, layoutInsets: .zero),
                item(title: viewModel.createdAtLabelTitle, value: viewModel.createdAt),
            ]),
            TransactionAppearance.divider(color: dividerColor, alpha: 1, layoutInsets: dividerOffset),
            item(title: viewModel.nonceTitle, value: viewModel.nonce),
            TransactionAppearance.divider(color: dividerColor, alpha: 1, layoutInsets: dividerOffset),
        ]

        if viewModel.detailsAvailable {
            items.append(moreDetails())
        }

        for item in items {
            stackViewController.addItem(item)
        }
        stackViewController.stackView.preservesSuperviewLayoutMargins = true

        displayChildViewController(viewController: stackViewController)

        if viewModel.shareAvailable {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(_:)))
        }
    }

    private func item(
        title: String,
        value: String,
        subTitleMinimumScaleFactor: CGFloat  = 0.7
    ) -> UIView {
        return  TransactionAppearance.item(
            title: title,
            subTitle: value,
            subTitleMinimumScaleFactor: subTitleMinimumScaleFactor
        ) { [weak self] in
            self?.showAlertSheet(title: $0, value: $1, sourceView: $2)
        }
    }

    private func moreDetails() -> UIView {
        let button = Button(size: .large, style: .border)
        button.setTitle(NSLocalizedString("More Details", value: "More Details", comment: ""), for: .normal)
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

    func showAlertSheet(title: String, value: String, sourceView: UIView) {
        let alertController = UIAlertController(
            title: nil,
            message: value,
            preferredStyle: .actionSheet
        )
        alertController.popoverPresentationController?.sourceView = sourceView
        alertController.popoverPresentationController?.sourceRect = sourceView.bounds
        let copyAction = UIAlertAction(title: NSLocalizedString("Copy", value: "Copy", comment: ""), style: .default) { _ in
            UIPasteboard.general.string = value
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.cancel(), style: .cancel) { _ in }
        alertController.addAction(copyAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    @objc func more() {
        guard let url = viewModel.detailsURL else { return }
        delegate?.didPressURL(url)
    }

    @objc func share(_ sender: UIBarButtonItem) {
        guard let item = viewModel.shareItem else { return }
        let activityViewController = UIActivityViewController.make(items: [item])
        activityViewController.popoverPresentationController?.barButtonItem = sender
        navigationController?.present(activityViewController, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
