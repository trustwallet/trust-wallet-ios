// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class ExchangeViewController: UIViewController {

    private let viewModel = ExchangeViewModel()
    let exchangeFields = ExchangeTokensField()
    let coordinator = ExchangeToksnCoordinator()

    init() {
        super.init(nibName: nil, bundle: nil)

        exchangeFields.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(exchangeFields)

        NSLayoutConstraint.activate([
            exchangeFields.topAnchor.constraint(equalTo: view.layoutGuide.topAnchor, constant: 20),
            exchangeFields.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            exchangeFields.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        exchangeFields.didPressSwap = { [unowned self] in
            self.coordinator.swap()
        }
        exchangeFields.didPressFrom = { [unowned self] in
            self.showSelectToken(direction: .from)
        }
        exchangeFields.didPressTo = { [unowned self] in
            self.showSelectToken(direction: .to)
        }

        coordinator.didUpdate = { [weak self] viewModel in
            guard let `self` = self else { return }
            self.configure(viewModel: viewModel)
        }
        configure(viewModel: coordinator.viewModel)

        view.backgroundColor = viewModel.backgroundColor
        navigationItem.title = viewModel.title
    }

    func configure(viewModel: ExchangeTokensViewModel) {
        exchangeFields.to.symbolLabel.text = viewModel.toSymbol
        exchangeFields.from.symbolLabel.text = viewModel.fromSymbol
    }

    func showSelectToken(direction: SelectTokenDirection) {
        let controller = SelectTokenViewController(
            tokens: coordinator.tokens,
            direction: direction
        )
        controller.delegate = self
        navigationController?.pushViewController(controller, animated: true)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExchangeViewController: SelectTokenViewControllerDelegate {
    func didSelect(token: ExchangeToken, in viewController: SelectTokenViewController) {
        coordinator.changeToken(direction: viewController.direction, token: token)
    }
}
