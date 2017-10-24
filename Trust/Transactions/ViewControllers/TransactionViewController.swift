// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StackViewController
import Result

class TransactionViewController: UIViewController {

    private lazy var viewModel: TransactionViewModel = {
        return .init(transaction: self.transaction)
    }()
    let stackViewController = StackViewController()

    let transaction: Transaction

    init(transaction: Transaction) {
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

        let value = EthereumConverter.from(value: BInt(transaction.value), to: .ether, minimumFractionDigits: 5)

        let items: [UIView] = [
            .spacer(),
            TransactionAppearance.header(
                viewModel: TransactionHeaderViewModel(
                    amount: Double(value) ?? 0,
                    direction: transaction.direction
                )
            ),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            TransactionAppearance.item(title: "From", subTitle: transaction.from),
            TransactionAppearance.item(title: "To", subTitle: transaction.to),
            TransactionAppearance.item(title: "Gas Fee", subTitle: gasFee),
            TransactionAppearance.item(title: "Confirmation", subTitle: String(transaction.confirmations)),
            TransactionAppearance.divider(color: Colors.lightGray, alpha: 0.3),
            TransactionAppearance.item(title: "Transaction #", subTitle: transaction.to),
            TransactionAppearance.item(title: "Transaction time", subTitle: viewModel.createdAt),
            TransactionAppearance.item(title: "Block #", subTitle: transaction.blockNumber),
        ]

        for item in items {
            stackViewController.addItem(item)
        }

        displayChildViewController(viewController: stackViewController)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
