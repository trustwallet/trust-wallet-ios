// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StatefulViewController

class TransactionsEmptyView: UIView {

    let titleLabel = UILabel()
    let imageView = UIImageView()
    let button = Button(size: .normal, style: .solid)
    let depositButton = Button(size: .normal, style: .solid)
    let insets: UIEdgeInsets
    private var onRetry: (() -> Void)? = .none
    var onDeposit: ((_ sender: UIButton) -> Void)? = .none
    private let viewModel = StateViewModel()

    var isDepositAvailable: Bool = true {
        didSet {
            depositButton.isHidden = !isDepositAvailable
        }
    }

    init(
        title: String = NSLocalizedString("transactions.noTransactions.label.title", value: "No Transactions Yet!", comment: ""),
        image: UIImage? = R.image.no_transactions_mascot(),
        insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
        onRetry: (() -> Void)? = .none,
        onDeposit: ((_ sender: UIButton) -> Void)? = .none
    ) {
        self.insets = insets
        self.onRetry = onRetry
        self.onDeposit = onDeposit
        super.init(frame: .zero)

        backgroundColor = .white

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = title
        titleLabel.font = viewModel.descriptionFont
        titleLabel.textColor = viewModel.descriptionTextColor

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = image

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(R.string.localizable.refresh(), for: .normal)
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)

        depositButton.translatesAutoresizingMaskIntoConstraints = false
        depositButton.setTitle(NSLocalizedString("transactions.deposit.button.title", value: "Buy", comment: ""), for: .normal)
        depositButton.addTarget(self, action: #selector(deposit(_:)), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            titleLabel,
            //depositButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 30

        if let _ = onRetry {
            stackView.addArrangedSubview(button)
        }

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 180),
            depositButton.widthAnchor.constraint(equalToConstant: 180),
        ])
    }

    @objc func retry() {
        onRetry?()
    }

    @objc func deposit(_ sender: UIButton) {
        onDeposit?(sender)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TransactionsEmptyView: StatefulPlaceholderView {
    func placeholderViewInsets() -> UIEdgeInsets {
        return insets
    }
}
