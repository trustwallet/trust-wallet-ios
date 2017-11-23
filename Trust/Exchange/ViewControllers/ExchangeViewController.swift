// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

class ExchangeViewController: UIViewController {

    private let viewModel = ExchangeViewModel()
    let exchangeFields = ExchangeTokensField()
    let currencyView = ExchangeCurrencyView()
    let coordinator = ExchangeToksnCoordinator()

    init() {
        super.init(nibName: nil, bundle: nil)

        exchangeFields.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [
            exchangeFields,
            .spacer(height: 20),
            currencyView,
        ])
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.layoutGuide.topAnchor, constant: 20),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: view.bottomAnchor, constant: -20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])

        exchangeFields.didPress = { [unowned self] direction in
            self.showSelectToken(direction: direction)
        }
        exchangeFields.didPressAvailableBalance = { [unowned self] _ in
            self.exchangeFields.fromField.amountField.text = "\(self.coordinator.viewModel.availableBalance)"
        }

        coordinator.didUpdate = { [weak self] viewModel in
            guard let `self` = self else { return }
            self.configure(viewModel: viewModel)
        }
        configure(viewModel: coordinator.viewModel)

        view.backgroundColor = viewModel.backgroundColor
        navigationItem.title = viewModel.title
        exchangeFields.backgroundColor = .white
    }

    func configure(viewModel: ExchangeTokensViewModel) {
        exchangeFields.fromField.symbolLabel.text = viewModel.fromSymbol
        exchangeFields.toField.symbolLabel.text = viewModel.toSymbol

        exchangeFields.fromField.backgroundColor = Colors.veryLightGray
        exchangeFields.toField.backgroundColor = Colors.veryLightGray

        exchangeFields.availableBalanceLabel.attributedText = viewModel.attributedAvailableBalance
        currencyView.currencyLabel.attributedText = viewModel.attributedCurrency
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
        navigationController?.popViewController(animated: true)
    }
}
