// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import StatefulViewController
import Result
import TrustCore
import RealmSwift

protocol TokensViewControllerDelegate: class {
    func didPressAddToken( in viewController: UIViewController)
    func didSelect(token: TokenObject, in viewController: UIViewController)
    func didDelete(token: TokenObject, in viewController: UIViewController)
    func didEdit(token: TokenObject, in viewController: UIViewController)
    func didDisable(token: TokenObject, in viewController: UIViewController)
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

    lazy var footerView: ButtonsFooterView = {
        let footerView = ButtonsFooterView(
            frame: .zero
        )
        footerView.translatesAutoresizingMaskIntoConstraints = false
        footerView.setTopBorder()
        return footerView
    }()

    let tableView: UITableView
    let refreshControl = UIRefreshControl()
    weak var delegate: TokensViewControllerDelegate?
    var etherFetchTimer: Timer?
    let intervalToETHRefresh = 10.0

    init(
        viewModel: TokensViewModel
    ) {
        self.viewModel = viewModel
        tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = StyleLayout.TableView.separatorColor
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(footerView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: footerView.topAnchor),

            footerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.bottomAnchor.constraint(equalTo: view.layoutGuide.bottomAnchor),
        ])
        tableView.register(TokenViewCell.self, forCellReuseIdentifier: TokenViewCell.identifier)
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        errorView = ErrorView(onRetry: { [weak self] in
            self?.startLoading()
            self?.fetch()
        })
        loadingView = LoadingView()
        emptyView = EmptyView(
            title: NSLocalizedString("emptyView.noTokens.label.title", value: "You haven't received any tokens yet!", comment: ""),
            onRetry: { [weak self] in
                self?.startLoading()
                self?.fetch()
        })
        tableView.tableHeaderView = header
        tableView.tableFooterView = footer
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.applyTintAdjustment()
        fetch()
    }

    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch()
    }

    func fetch() {
        self.startLoading()
        self.viewModel.fetch()
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
                self?.endLoading()
            case .error(let error):
                self?.endLoading(animated: true, error: error, completion: nil)
            }
            if strongSelf.refreshControl.isRefreshing {
                strongSelf.refreshControl.endRefreshing()
            }
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
            self?.viewModel.updateEthBalance()
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
extension TokensViewController: StatefulViewController {
    func hasContent() -> Bool {
        return viewModel.hasContent
    }
}
extension TokensViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let token = viewModel.item(for: indexPath)
        delegate?.didSelect(token: token, in: self)
    }
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let token = viewModel.item(for: indexPath)
        let delete = UITableViewRowAction(style: .destructive, title: R.string.localizable.delete()) {[unowned self] (_, _) in
            self.delegate?.didDelete(token: token, in: self)
        }
        let edit = UITableViewRowAction(style: .normal, title: R.string.localizable.edit()) {[unowned self] (_, _) in
            self.delegate?.didEdit(token: token, in: self)
        }
        let disable = UITableViewRowAction(style: .normal, title: R.string.localizable.disable()) {[unowned self] (_, _) in
            self.delegate?.didDisable(token: token, in: self)
        }

        if viewModel.canEdit(for: indexPath) {
            return [delete, disable, edit]
        } else if viewModel.canDisable(for: indexPath) {
            return [disable]
        } else {
            return []
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return TokensLayout.tableView.height
    }
}
extension TokensViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TokenViewCell.identifier, for: indexPath) as! TokenViewCell
        cell.configure(viewModel: viewModel.cellViewModel(for: indexPath))
        cell.contentView.isExclusiveTouch = true
        cell.isExclusiveTouch = true
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tokens.count
    }
}
extension TokensViewController: TokensViewModelDelegate {
    func refresh() {
        self.tableView.reloadData()
        self.refreshHeaderView()
    }
}
