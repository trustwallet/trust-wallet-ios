// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import BigInt

struct SubmitExchangeToken {
    let token: ExchangeToken
    let amount: BigInt
}

protocol ExchangeViewControllerDelegate: class {
    func didPress(from: SubmitExchangeToken, to: SubmitExchangeToken, in viewController: ExchangeViewController)
}

class ExchangeViewController: UIViewController {

    private let viewModel = ExchangeViewModel()
    let exchangeFields = ExchangeTokensField()
    let currencyView = ExchangeCurrencyView()
    lazy var nextButton: UIButton = {
        let button = Button(size: .normal, style: .solid)
        button.setTitle(viewModel.nextButtonText, for: .normal)
        button.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        return button
    }()
    let session: WalletSession
    lazy var coordinator: ExchangeTokensCoordinator = {
        return ExchangeTokensCoordinator(
            session: self.session,
            tokens: ExchangeTokens.get(for: Config().server)
        )
    }()
    weak var delegate: ExchangeViewControllerDelegate?

    init(
        session: WalletSession
    ) {
        self.session = session

        super.init(nibName: nil, bundle: nil)

        exchangeFields.translatesAutoresizingMaskIntoConstraints = false
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        currencyView.translatesAutoresizingMaskIntoConstraints = false

        let stackView = UIStackView(arrangedSubviews: [
            currencyView,
            exchangeFields,
            .spacer(height: 20),
            nextButton,
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
        exchangeFields.didPressAvailableBalance = { [unowned self] in
            self.exchangeFields.fromField.amountField.text = "\(self.coordinator.viewModel.availableBalance)"
            self.exchangeFields.fromField.amountDidChange(self.exchangeFields.fromField.amountField)
        }
        exchangeFields.didChangeValue = { [unowned self] (direction, value) in

            func clean(value: Double) -> String {
                if value == 0 { return "" }
                return "\(value)"
            }

            guard let rateDouble = self.coordinator.viewModel.rateDouble else { return }
            switch direction {
            case .from:
                self.exchangeFields.toField.amountField.text = clean(value: value * rateDouble)
            case .to:
                self.exchangeFields.fromField.amountField.text = clean(value: (value / rateDouble))
            }
        }

        coordinator.didUpdate = { [weak self] viewModel in
            guard let `self` = self else { return }
            self.configure(viewModel: viewModel)
        }
        configure(viewModel: coordinator.viewModel)

        view.backgroundColor = viewModel.backgroundColor
        navigationItem.title = viewModel.title
        exchangeFields.backgroundColor = .white

        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        coordinator.fetch()
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    func configure(viewModel: ExchangeTokensViewModel) {
        exchangeFields.fromField.symbolLabel.text = viewModel.fromSymbol
        exchangeFields.fromField.tokenImageView.image = viewModel.fromImage
        exchangeFields.fromField.backgroundColor = Colors.veryLightGray

        exchangeFields.toField.symbolLabel.text = viewModel.toSymbol
        exchangeFields.toField.tokenImageView.image = viewModel.toImage
        exchangeFields.toField.backgroundColor = Colors.veryLightGray

        exchangeFields.availableBalanceLabel.attributedText = viewModel.attributedAvailableBalance
        exchangeFields.availableBalanceLabel.alpha = 0.7
        exchangeFields.availableBalanceLabel.textAlignment = .left
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

    @objc func nextAction() {
        let from = coordinator.from
        let to = coordinator.to
        let fromInput = exchangeFields.fromField.amountField.text ?? ""
        let toInput = exchangeFields.toField.amountField.text ?? ""

        let formatter = EtherNumberFormatter.full
        guard
            let fromAmount = formatter.number(from: fromInput, decimals: from.decimals),
            let toAmount = formatter.number(from: toInput, decimals: to.decimals) else {
            return displayError(error: ExchangeTokenError.wrongInput)
        }

        delegate?.didPress(
            from: SubmitExchangeToken(token: from, amount: fromAmount),
            to: SubmitExchangeToken(token: to, amount: toAmount),
            in: self
        )
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
