// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

final class InfoHeaderView: UIView {

    let amountLabel = UILabel(frame: .zero)
    let logoImageView = UIImageView(frame: .zero)
    let label = UILabel(frame: .zero)

    override init(frame: CGRect = .zero) {

        super.init(frame: frame)

        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.contentMode = .scaleAspectFit

        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2

        addSubview(logoImageView)
        addSubview(label)

        NSLayoutConstraint.activate([
            logoImageView.widthAnchor.constraint(equalToConstant: 70),
            logoImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            logoImageView.trailingAnchor.constraint(equalTo: label.leadingAnchor, constant: -20),
            logoImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),

            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])

        backgroundColor = .clear
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
