// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StackViewController
import Result
import SafariServices

class TransactionViewController: UIViewController {

    private lazy var viewModel: TransactionViewModel = {
        return .init(transaction: self.transaction, config: self.config)
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

        let gasUsed = BInt(String(transaction.gasUsed))
        let gasPrice = BInt(String(transaction.gasPrice))
        let gasFee = EthereumConverter.from(
            value: gasPrice * gasUsed,
            to: .ether,
            minimumFractionDigits: 5,
            maximumFractionDigits: 5
        )

        let confirmation = session.chainState.latestBlock - Int(transaction.blockNumber)

        let items: [UIView] = [
            .spacer(),
            TransactionAppearance.header(
                viewModel: TransactionHeaderViewModel(
                    value: viewModel.value,
                    direction: transaction.direction
                )
            ),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            TransactionAppearance.item(title: "From", subTitle: transaction.from),
            TransactionAppearance.item(title: "To", subTitle: transaction.to),
            TransactionAppearance.item(title: "Gas Fee", subTitle: gasFee),
            TransactionAppearance.item(title: "Confirmation", subTitle: String(confirmation)),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            TransactionAppearance.item(title: "Transaction #", subTitle: transaction.to),
            TransactionAppearance.item(title: "Transaction time", subTitle: viewModel.createdAt),
            TransactionAppearance.item(title: "Block #", subTitle: String(transaction.blockNumber)),
            moreDetails(),
        ]

        for item in items {
            stackViewController.addItem(item)
        }

        displayChildViewController(viewController: stackViewController)
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

    func more() {
        let controller = SFSafariViewController(url: viewModel.detailsURL)
        present(controller, animated: true, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
