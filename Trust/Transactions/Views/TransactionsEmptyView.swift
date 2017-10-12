// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import StatefulViewController

class TransactionsEmptyView: UIView {

    let label = UILabel()
    let imageView = UIImageView()
    let button = Button(size: .normal, style: .borderless)
    let walletButton = Button(size: .normal, style: .solid)
    let insets: UIEdgeInsets
    var onRetry: (() -> Void)? = .none
    var onWalletPress: (() -> Void)? = .none

    init(
        insets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0),
        onRetry: (() -> Void)? = .none,
        onWalletPress: (() -> Void)? = .none
    ) {
        self.insets = insets
        self.onRetry = onRetry
        self.onWalletPress = onWalletPress
        super.init(frame: .zero)

        backgroundColor = .white

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = Localized("Transactions.NoTransactions", value: "No Transactions")

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = nil

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(Localized("Generic.Refresh", value: "Refresh"), for: .normal)
        button.addTarget(self, action: #selector(retry), for: .touchUpInside)

        walletButton.translatesAutoresizingMaskIntoConstraints = false
        walletButton.setTitle(Localized("Transactions.SeeMyAddress", value: "See my address"), for: .normal)
        walletButton.titleLabel?.adjustsFontSizeToFitWidth = true
        walletButton.addTarget(self, action: #selector(seeWallet), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            label,
            imageView,
            button,
            UIView(),
            walletButton,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .center
        stackView.axis = .vertical
        stackView.spacing = 12

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 180),
            walletButton.widthAnchor.constraint(equalToConstant: 180),
        ])
    }

    func retry() {
        onRetry?()
    }

    func seeWallet() {
        onWalletPress?()
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
