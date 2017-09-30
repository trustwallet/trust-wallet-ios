// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StackViewController

class TransactionViewController: UIViewController {

    private lazy var viewModel: TransactionViewModel = {
        return .init(transaction: self.transaction)
    }()
    let stackViewController = StackViewController()

    let transaction: Transaction
    let refreshControl = UIRefreshControl()

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

        displayStackViewController()

        let items: [UIView] = [
            spacer(),
            header(),
            divider(),
            item(title: "From", subTitle: transaction.from),
            item(title: "To", subTitle: transaction.to),
            item(title: "Gas Fee", subTitle: gasFee),
            item(title: "Confirmation", subTitle: String(transaction.confirmations)),
            divider(),
            item(title: "Transaction #", subTitle: transaction.to),
            item(title: "Transaction time", subTitle: viewModel.createdAt),
            item(title: "Block #", subTitle: transaction.blockNumber),
        ]

        for item in items {
            stackViewController.addItem(item)
        }

        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        stackViewController.scrollView.addSubview(refreshControl)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    private func displayStackViewController() {
        addChildViewController(stackViewController)
        view.addSubview(stackViewController.view)
        _ = stackViewController.view.activateSuperviewHuggingConstraints()
        stackViewController.didMove(toParentViewController: self)
    }

    func pullToRefresh() {
        fetch()
    }

    func fetch() {
        refreshControl.beginRefreshing()
        refreshControl.endRefreshing()
    }

    private func item(title: String, subTitle: String) -> UIView {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.textColor = Colors.gray

        let subTitleLabel = UILabel(frame: .zero)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.text = subTitle
        subTitleLabel.textAlignment = .left
        subTitleLabel.textColor = Colors.black
        subTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        subTitleLabel.adjustsFontSizeToFitWidth = true

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true
        return stackView
    }

    private func divider() -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = Colors.lightGray
        view.alpha = 0.3
        view.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return view
    }

    private func spacer() -> UIView {
        let view = UIView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }

    private func header() -> UIView {
        let view = TransactionHeaderView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.amountLabel.attributedText = viewModel.amountAttributedString
        return view
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
