// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

protocol WalletTitleViewDelegate: class {
    func didTap(in view: WalletTitleView)
}

final class WalletTitleView: UIView {

    var title: String = "" {
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
        button.layer.cornerRadius = 5
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        button.titleLabel?.adjustsFontSizeToFitWidth = true

        addSubview(button)

        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),

            leadingAnchor.constraint(equalTo: button.leadingAnchor),
            trailingAnchor.constraint(equalTo: button.trailingAnchor),

            heightAnchor.constraint(equalToConstant: 32),
            widthAnchor.constraint(lessThanOrEqualToConstant: 160),
        ])
    }

    @objc private func press() {
        self.delegate?.didTap(in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
