// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class ExchangeTokenView: UIView {

    let imageView = UIImageView()
    let label = UILabel()

    init() {

        super.init(frame: .zero)

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "ETH"

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = R.image.accounts_active()

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            label,
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 100),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
