// Copyright SIX DAY LLC. All rights reserved.

import TrustCore
import UIKit
import PromiseKit

protocol AccountsViewControllerDelegate: class {
    func didSelectAccount(account: WalletInfo, in viewController: AccountsViewController)
    func didDeleteAccount(account: WalletInfo, in viewController: AccountsViewController)
    func didSelectInfoForAccount(account: WalletInfo, sender: UIView, in viewController: AccountsViewController)
}

class AccountsViewController: UITableViewController {
    weak var delegate: AccountsViewControllerDelegate?
    var viewModel: AccountsViewModel {
        return AccountsViewModel(
            wallets: wallets,
            current: session.account
        )
    }
    var hasWallets: Bool {
        return !wallets.isEmpty
    }

    var wallets: [WalletInfo] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    private let keystore: Keystore
    private let balanceCoordinator: TokensBalanceService
    private let config = Config()
    private let session: WalletSession

    init(
        keystore: Keystore,
        session: WalletSession,
        balanceCoordinator: TokensBalanceService
    ) {
        self.keystore = keystore
        self.session = session
        self.balanceCoordinator = balanceCoordinator
        super.init(style: .grouped)

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(R.nib.accountViewCell(), forCellReuseIdentifier: R.nib.accountViewCell.name)
        configure(viewModel: viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetch()
    }

    func fetch() {
        wallets = keystore.wallets
    }

    func configure(viewModel: AccountsViewModel) {
        title = viewModel.title
    }

    func wallet(for indexPath: IndexPath) -> WalletInfo? {
        return viewModel.wallet(for: indexPath)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.accountViewCell.name, for: indexPath) as! AccountViewCell
        cell.viewModel = getAccountViewModels(for: indexPath)
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.canEditRowAt(for: indexPath)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete, let wallet = self.wallet(for: indexPath) {
            confirmDelete(wallet: wallet)
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.titleForHeader(in: section)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.headerHeight(in: section)
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return viewModel.footerHeight(in: section)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let wallet = self.wallet(for: indexPath) else { return }
        delegate?.didSelectAccount(account: wallet, in: self)
    }

    func confirmDelete(wallet: WalletInfo) {
        confirm(
            title: NSLocalizedString("accounts.confirm.delete.title", value: "Are you sure you would like to delete this wallet?", comment: ""),
            message: NSLocalizedString("accounts.confirm.delete.message", value: "Make sure you have backup of your wallet.", comment: ""),
            okTitle: NSLocalizedString("accounts.confirm.delete.okTitle", value: "Delete", comment: ""),
            okStyle: .destructive
        ) { [weak self] result in
            switch result {
            case .success:
                self?.delete(wallet: wallet)
            case .failure: break
            }
        }
    }

    func delete(wallet: WalletInfo) {
        navigationController?.displayLoading(text: R.string.localizable.deleting())
        keystore.delete(wallet: wallet.wallet) { [weak self] result in
            guard let `self` = self else { return }
            self.navigationController?.hideLoading()
            switch result {
            case .success:
                self.fetch()
                self.delegate?.didDeleteAccount(account: wallet, in: self)
            case .failure(let error):
                self.displayError(error: error)
            }
        }
    }

    private func getAccountViewModels(for path: IndexPath) -> AccountViewModel {
        return AccountViewModel(
            server: config.server,
            wallet: self.wallet(for: path)!,
            current: session.account
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AccountsViewController: AccountViewCellDelegate {
    func accountViewCell(_ cell: AccountViewCell, didTapInfoViewForAccount account: WalletInfo) {
        self.delegate?.didSelectInfoForAccount(account: account, sender: cell.infoButton, in: self)
    }
}
