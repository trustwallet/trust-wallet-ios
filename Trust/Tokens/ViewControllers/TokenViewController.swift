// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Kingfisher

protocol TokenViewControllerDelegate: class {
    func didPressRequest(for type: TokenType, in controller: UIViewController)
    func didPressSend(for type: TokenType, in controller: UIViewController)
}

class TokenViewController: UIViewController {

    let tableView = UITableView()
    let headerView = TokenHeaderView()
    let viewModel: TokenViewModel
    weak var delegate: TokenViewControllerDelegate?

    init(viewModel: TokenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        configure(with: viewModel)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        headerView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(headerView)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 240),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        headerView.buttonsView.requestButton.addTarget(self, action: #selector(request), for: .touchUpInside)
        headerView.buttonsView.sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)
    }

    func configure(with viewModel: TokenViewModel) {
        navigationItem.title = viewModel.title
        headerView.imageView.kf.setImage(
            with: viewModel.imageURL,
            placeholder: viewModel.imagePlaceholder
        )
        headerView.amountLabel.text = viewModel.amountText
        headerView.amountLabel.font = viewModel.amountFont
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func send() {
        delegate?.didPressSend(for: viewModel.type, in: self)
    }

    @objc func request() {
        delegate?.didPressRequest(for: viewModel.type, in: self)
    }
}
