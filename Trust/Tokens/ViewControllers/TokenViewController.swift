// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Kingfisher

protocol TokenViewControllerDelegate: class {
    func didPressRequest(for token: TokenObject, in controller: UIViewController)
    func didPressSend(for token: TokenObject, in controller: UIViewController)
}

class TokenViewController: UIViewController {

    private let refreshControl = UIRefreshControl()

    private var tableView = UITableView()

    private lazy var header: TokenHeaderView = {
        let view = TokenHeaderView()
        view.imageView.kf.setImage(
            with: viewModel.imageURL,
            placeholder: viewModel.imagePlaceholder
        )
        view.amountLabel.text = viewModel.amount
        view.amountLabel.font = viewModel.amountFont
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private var viewModel: TokenViewModel

    weak var delegate: TokenViewControllerDelegate?

    init(viewModel: TokenViewModel) {
        self.viewModel = viewModel
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.title = viewModel.title
        view.backgroundColor = .white

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.tableHeaderView = header

        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)

        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            header.topAnchor.constraint(equalTo: tableView.topAnchor),
            header.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            header.widthAnchor.constraint(equalTo: tableView.widthAnchor),
            header.heightAnchor.constraint(equalToConstant: 240),
        ])

        header.buttonsView.requestButton.addTarget(self, action: #selector(request), for: .touchUpInside)
        header.buttonsView.sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)

        observToken()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func observToken() {
        viewModel.tokenObservation { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.updateHeader()
        }
    }

    private func updateHeader() {
         header.amountLabel.text = viewModel.amount
    }

    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        viewModel.fetch()
    }

    @objc func send() {
        delegate?.didPressSend(for: viewModel.token, in: self)
    }

    @objc func request() {
        delegate?.didPressRequest(for: viewModel.token, in: self)
    }
}
