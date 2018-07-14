// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
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

    let tableView: UITableView = {
        let tableView =  UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = StyleLayout.TableView.separatorColor
        tableView.backgroundColor = .white
        tableView.register(TokenViewCell.self, forCellReuseIdentifier: TokenViewCell.identifier)
        return tableView
    }()

    lazy var titleView: WalletTitleView = {
        let view = WalletTitleView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let refreshControl = UIRefreshControl()
    weak var delegate: TokensViewControllerDelegate?
    var etherFetchTimer: Timer?
    let intervalToETHRefresh = 10.0

    init(
        viewModel: TokensViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.viewModel.delegate = self

        tableViewConfigiration()
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

        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        scheduleBalanceUpdate()
        NotificationCenter.default.addObserver(self, selector: #selector(TokensViewController.resignActive), name: .UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TokensViewController.didBecomeActive), name: .UIApplicationDidBecomeActive, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.viewModel.updateEthBalance()
        self.viewModel.tokensInfo()
        self.viewModel.updatePendingTransactions()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func refreshHeaderView() {
        viewModel.amount(completion: { [weak self] value in
            self?.header.amountLabel.text = value
        })
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
                strongSelf.reload()
            case .update(_, let deletions, let insertions, let updates):
                UIView.setAnimationsEnabled(false)
                let fromRow = { (row: Int) in return IndexPath(row: row, section: 0) }
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map(fromRow), with: .none)
                tableView.reloadRows(at: updates.map(fromRow), with: .none)
                tableView.deleteRows(at: deletions.map(fromRow), with: .none)
                tableView.endUpdates()
                UIView.setAnimationsEnabled(true)
            case .error:
                break
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
        startTokenObservation()
        fetch()
        scheduleBalanceUpdate()
    }

    private func scheduleBalanceUpdate() {
        guard etherFetchTimer == nil else { return }
        etherFetchTimer = Timer.scheduledTimer(timeInterval: intervalToETHRefresh, target: BlockOperation { [weak self] in
            self?.viewModel.updateEthBalance()
            self?.viewModel.updatePendingTransactions()
        }, selector: #selector(Operation.main), userInfo: nil, repeats: true)
    }

    private func stopTokenObservation() {
        viewModel.invalidateTokensObservation()
    }

    private func tableViewConfigiration() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.addSubview(refreshControl)
        tableView.tableHeaderView = header
        tableView.tableFooterView = footer
        navigationItem.titleView = titleView
        titleView.title = viewModel.headerViewTitle
    }

    fileprivate func reload() {
        UIView.setAnimationsEnabled(false)
        tableView.beginUpdates()
        tableView.reloadData()
        tableView.endUpdates()
        UIView.setAnimationsEnabled(true)
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
        refreshControl.endRefreshing()
        reload()
        refreshHeaderView()
    }
}

extension TokensViewController: Scrollable {
    func scrollOnTop() {
        tableView.scrollOnTop()
    }
}
