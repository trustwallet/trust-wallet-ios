// Copyright SIX DAY LLC, Inc. All rights reserved.

import UIKit
import ActiveLabel

class TransactionViewController: UIViewController {

    private lazy var viewModel: TransactionViewModel = {
        return .init(transaction: self.transaction)
    }()

    let transaction: Transaction

    let stackView: UIStackView
    let amountLabel = UILabel()
    let memoLabel = UILabel()

    init(transaction: Transaction) {
        self.transaction = transaction

        stackView = UIStackView(arrangedSubviews: [amountLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12

        super.init(nibName: nil, bundle: nil)

        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor

        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.topAnchor, constant: Layout.sideMargin + 64),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -Layout.sideMargin),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -Layout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: Layout.sideMargin),
        ])

        let gasUsed = BInt(String(transaction.gasUsed))
        let gasPrice = BInt(String(transaction.gasPrice))
        let gasFee = EthereumConverter.from(
            value: gasPrice * gasUsed,
            to: .ether,
            minimumFractionDigits: 5,
            maximumFractionDigits: 5
        )

        let items: [UIView] = [
            spacer(),
            header(),
            spacer(),
            divider(),
            item(title: "From", subTitle: transaction.from),
            item(title: "To", subTitle: transaction.to),
            item(title: "Gas Fee", subTitle: gasFee),
            item(title: "Confirmation", subTitle: transaction.confirmations + " 0x"),
            divider(),
            item(title: "Transaction #", subTitle: transaction.to),
            item(title: "Block #", subTitle: transaction.blockNumber),
        ]

        let _ = items.map(stackView.addArrangedSubview)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    private func item(title: String, subTitle: String) -> UIView {
        let titleLabel = UILabel(frame: .zero)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.textAlignment = .left
        titleLabel.textColor = Colors.gray

        let ethereumAddress = ActiveType.ethereumAddress()
        let subTitleLabel = ActiveLabel(frame: .zero)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.text = subTitle
        subTitleLabel.textAlignment = .left
        subTitleLabel.textColor = Colors.black
        subTitleLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFontWeightLight)
        subTitleLabel.adjustsFontSizeToFitWidth = true
        subTitleLabel.enabledTypes = [ethereumAddress]
        subTitleLabel.handleCustomTap(for: ethereumAddress) { action in
        }

        let stackView = UIStackView(arrangedSubviews: [titleLabel, subTitleLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 4
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
        let amountLabel = UILabel(frame: .zero)
        amountLabel.translatesAutoresizingMaskIntoConstraints = false
        amountLabel.attributedText = viewModel.amountAttributedString
        amountLabel.textAlignment = .center
        return amountLabel
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
