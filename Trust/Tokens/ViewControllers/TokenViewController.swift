// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import Kingfisher

protocol TokenViewControllerDelegate: class {
    func didPressRequest(for token: TokenObject, in controller: UIViewController)
    func didPressSend(for token: TokenObject, in controller: UIViewController)
    func didPress(transaction: Transaction, in controller: UIViewController)
}

class TokenViewController: UIViewController {

    private let refreshControl = UIRefreshControl()

    private var tableView = UITableView()

    private lazy var header: TokenHeaderView = {
        let view = TokenHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 264))
        return view
    }()

    private var viewModel: TokenViewModel

    weak var delegate: TokenViewControllerDelegate?

    init(viewModel: TokenViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)

        navigationItem.title = viewModel.title
        view.backgroundColor = .white

        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 68
        tableView.tableHeaderView = header

        tableView.register(TransactionViewCell.self, forCellReuseIdentifier: TransactionViewCell.identifier)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])

        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)

        header.buttonsView.requestButton.addTarget(self, action: #selector(request), for: .touchUpInside)
        header.buttonsView.sendButton.addTarget(self, action: #selector(send), for: .touchUpInside)

        observToken()
        observTransactions()

        updateHeader()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetch()
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

    private func observTransactions() {
        viewModel.transactionObservation { [weak self] in
            self?.refreshControl.endRefreshing()
            self?.tableView.reloadData()
        }
    }

    private func updateHeader() {
        header.imageView.kf.setImage(
            with: viewModel.imageURL,
            placeholder: viewModel.imagePlaceholder
        )
        header.amountLabel.text = viewModel.amount
        header.amountLabel.font = viewModel.amountFont
        header.amountLabel.textColor = viewModel.amountTextColor

        header.fiatAmountLabel.text = viewModel.totalFiatAmount
        header.fiatAmountLabel.font = viewModel.fiatAmountFont
        header.fiatAmountLabel.textColor = viewModel.fiatAmountTextColor

//        header.currencyAmountLabel.text = viewModel.currencyAmount
//        header.currencyAmountLabel.textColor = viewModel.currencyAmountTextColor
//        header.currencyAmountLabel.font = viewModel.currencyAmountFont
//
//        header.percentChange.text = viewModel.percentChange
//        header.percentChange.textColor = viewModel.percentChangeColor
//        header.percentChange.font = viewModel.percentChangeFont
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

extension TokenViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionViewCell.identifier, for: indexPath) as! TransactionViewCell
        cell.configure(viewModel: viewModel.cellViewModel(for: indexPath))
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(for: section)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return viewModel.hederView(for: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return StyleLayout.TableView.heightForHeaderInSection
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didPress(transaction: viewModel.item(for: indexPath.row, section: indexPath.section), in: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
