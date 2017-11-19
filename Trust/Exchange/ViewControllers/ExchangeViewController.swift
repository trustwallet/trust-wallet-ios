// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class ExchangeViewController: UIViewController {

    private let viewModel = ExchangeViewModel()
    let exchangeFields = ExchangeTokensField()

    init() {
        super.init(nibName: nil, bundle: nil)

        exchangeFields.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exchangeFields)

        NSLayoutConstraint.activate([
            exchangeFields.topAnchor.constraint(equalTo: view.layoutGuide.topAnchor, constant: 15),
            exchangeFields.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 15),
            exchangeFields.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
        ])

        view.backgroundColor = viewModel.backgroundColor
        navigationItem.title = viewModel.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
