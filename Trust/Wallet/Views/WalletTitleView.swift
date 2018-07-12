// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

protocol WalletTitleViewDelegate: class {
    func didTap(in view: WalletTitleView)
}

final class WalletTitleView: UIView {

    var title: String = "Ethereum (Wallet 1)" {
        didSet {
            button.setTitle(title, for: .normal)
        }
    }

    private let button = UIButton()
    weak var delegate: WalletTitleViewDelegate?

    init() {
        super.init(frame: .zero)

        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        button.addTarget(self, action: #selector(press), for: .touchUpInside)

        addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),

            widthAnchor.constraint(equalToConstant: 200),
            heightAnchor.constraint(equalToConstant: 34),
        ])
    }

    @objc private func press() {
        self.delegate?.didTap(in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
