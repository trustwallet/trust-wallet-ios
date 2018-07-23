// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

protocol WalletCreatedControllerDelegate: class {
    func didPressDone(wallet: WalletInfo, in controller: WalletCreatedController)
}

final class WalletCreatedController: UIViewController {

    weak var delegate: WalletCreatedControllerDelegate?

    lazy var doneButton: UIButton = {
        let button = Button(size: .large, style: .solid)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(R.string.localizable.done(), for: .normal)
        button.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        return button
    }()

    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = ""
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.textAlignment = .center
        return titleLabel
    }()

    lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: R.image.mascot_happy())
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    let viewModel: WalletCreatedViewModel

    init(
        viewModel: WalletCreatedViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let stackView = UIStackView(arrangedSubviews: [
            imageView,
            .spacer(),
            .label(style: .heading, text: viewModel.type.title),
            .spacer(),
            TransactionAppearance.item(
                title: R.string.localizable.name(),
                subTitle: viewModel.title
            ),
            .spacer(),
            TransactionAppearance.item(
                title: R.string.localizable.myWalletAddress(),
                subTitle: viewModel.subtitle
            ),
        ])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.backgroundColor = .clear

        view.addSubview(stackView)
        view.addSubview(doneButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.topAnchor, constant: StyleLayout.sideMargin),
            stackView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            stackView.centerYAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.centerYAnchor, constant: -40),

            imageView.centerXAnchor.constraint(equalTo: stackView.centerXAnchor),

            doneButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            doneButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            doneButton.bottomAnchor.constraint(equalTo: view.readableContentGuide.bottomAnchor, constant: -StyleLayout.sideMargin),
        ])
    }

    @objc func doneAction() {
        delegate?.didPressDone(wallet: viewModel.wallet, in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
