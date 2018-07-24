// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import Result
import TrustCore
import RealmSwift

protocol TokensViewControllerDelegate: class {
    func didPressAddToken( in viewController: UIViewController)
    func didSelect(token: TokenObject, in viewController: UIViewController)
    func didRequest(token: TokenObject, in viewController: UIViewController)
}

final class TokensViewController: UIViewController {

    fileprivate var viewModel: TokensViewModel

    lazy var header: TokensHeaderView = {
        let header = TokensHeaderView(frame: .zero)
        header.amountLabel.text = viewModel.headerBalance
        header.amountLabel.textColor = viewModel.headerBalanceTextColor
        header.backgroundColor = viewModel.headerBackgroundColor
        header.amountLabel.font = viewModel.headerBalanceFont
        header.frame.size = header.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        return header
    }()

    lazy var footer: TokensFooterView = {
        let footer = TokensFooterView(frame: .zero)
        footer.textLabel.text = viewModel.footerTitle
        footer.textLabel.font = viewModel.footerTextFont
        footer.textLabel.textColor = viewModel.footerTextColor
        footer.frame.size = footer.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
        footer.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(missingToken))
        )
        return footer
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = StyleLayout.TableView.separatorColor
        tableView.backgroundColor = .white
        tableView.register(TokenViewCell.self, forCellReuseIdentifier: TokenViewCell.identifier)
        tableView.tableHeaderView = header
        tableView.tableFooterView = footer
        tableView.addSubview(refreshControl)
        return tableView
    }()

    let refreshControl = UIRefreshControl()
    weak var delegate: TokensViewControllerDelegate?
    var etherFetchTimer: Timer?
    let intervalToETHRefresh = 10.0

    lazy var fetchClosure: () -> Void = {
        return debounce(delay: .seconds(7), action: { [weak self] () in
            self?.viewModel.fetch()
        })
    }()

    init(
        viewModel: TokensViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        sheduleBalanceUpdate()
        NotificationCenter.default.addObserver(self, selector: #selector(TokensViewController.resignActive), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TokensViewController.didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        startTokenObservation()
        title = viewModel.title
        view.backgroundColor = viewModel.backgroundColor
        footer.textLabel.text = viewModel.footerTitle

        fetch(force: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.applyTintAdjustment()
    }

    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch(force: true)
    }

    func fetch(force: Bool = false) {
        if force {
            viewModel.fetch()
        } else {
            fetchClosure()
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshHeaderView() {
        header.amountLabel.text = viewModel.headerBalance
    }

    @objc func missingToken() {
        delegate?.didPressAddToken(in: self)
    }

    private func startTokenObservation() {
        viewModel.setTokenObservation { [weak self] (changes: RealmCollectionChange) in
            guard let strongSelf = self else { return }
            let tableView = strongSelf.tableView
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update:
                self?.tableView.reloadData()
            case .error: break
            }
            strongSelf.refreshControl.endRefreshing()
            self?.refreshHeaderView()
        }
    }

    @objc func resignActive() {
        etherFetchTimer?.invalidate()
        etherFetchTimer = nil
        stopTokenObservation()
    }

    @objc func didBecomeActive() {
        sheduleBalanceUpdate()
        startTokenObservation()
    }

    private func sheduleBalanceUpdate() {
        guard etherFetchTimer == nil else { return }
        etherFetchTimer = Timer.scheduledTimer(timeInterval: intervalToETHRefresh, target: BlockOperation { [weak self] in
            self?.viewModel.updatePendingTransactions()
        }, selector: #selector(Operation.main), userInfo: nil, repeats: true)
    }

    private func stopTokenObservation() {
        viewModel.invalidateTokensObservation()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        resignActive()
        stopTokenObservation()
    }
}

extension TokensViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let token = viewModel.item(for: indexPath)
        delegate?.didSelect(token: token, in: self)
    }

    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let token = viewModel.item(for: indexPath)
        let deleteAction = UIContextualAction(style: .normal, title: R.string.localizable.transactionsReceiveButtonTitle()) { _, _, handler in
            self.delegate?.didRequest(token: token, in: self)
            handler(true)
        }
        deleteAction.backgroundColor = Colors.lightBlue
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TokensLayout.tableView.height
    }
}
extension TokensViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TokenViewCell.identifier, for: indexPath) as! TokenViewCell
        cell.isExclusiveTouch = true
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tokens.count
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
       guard let tokenViewCell = cell as? TokenViewCell else { return }
       tokenViewCell.configure(viewModel: viewModel.cellViewModel(for: indexPath))
    }
}
extension TokensViewController: TokensViewModelDelegate {
    func refresh() {
        self.tableView.reloadData()
        self.refreshHeaderView()
    }
}
extension TokensViewController: Scrollable {
    func scrollOnTop() {
        tableView.scrollOnTop()
    }
}
