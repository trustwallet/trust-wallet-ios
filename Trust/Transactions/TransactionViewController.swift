// Copyright SIX DAY LLC, Inc. All rights reserved.

import UIKit

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
        stackView.spacing = 8

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

        let items: [UIView] = [
            spacer(),
            header(),
            spacer(),
            divider(),
            item(title: "From", subTitle: transaction.from),
            item(title: "To", subTitle: transaction.to),
            item(title: "Gas Fee", subTitle: transaction.gas),
            divider(),
            item(title: "Transaction #", subTitle: transaction.to),
            item(title: "Block #", subTitle: transaction.gas),
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

        let subTitleLabel = UILabel(frame: .zero)
        subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subTitleLabel.text = subTitle
        subTitleLabel.textAlignment = .left

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
