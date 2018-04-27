// Copyright SIX DAY LLC. All rights reserved.

import TrustCore
import UIKit

protocol AccountsViewControllerDelegate: class {
    func didSelectAccount(account: Wallet, in viewController: AccountsViewController)
    func didDeleteAccount(account: Wallet, in viewController: AccountsViewController)
    func didSelectInfoForAccount(account: Wallet, sender: UIView, in viewController: AccountsViewController)
}

class AccountsViewController: UITableViewController {
    weak var delegate: AccountsViewControllerDelegate?
    var headerTitle: String?
    var viewModel: AccountsViewModel {
        return AccountsViewModel(
            wallets: wallets
        )
    }
    var hasWallets: Bool {
        return !keystore.wallets.isEmpty
    }
    var wallets: [Wallet] = [] {
        didSet {
            tableView.reloadData()
            configure(viewModel: viewModel)
        }
    }
    private var balances: [Address: Balance?] = [:]
    private let keystore: Keystore
    private let balanceCoordinator: TokensBalanceService
    private let config = Config()

    init(
        keystore: Keystore,
        balanceCoordinator: TokensBalanceService
    ) {
        self.keystore = keystore
        self.balanceCoordinator = balanceCoordinator
        super.init(style: .grouped)
        fetch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(R.nib.accountViewCell(), forCellReuseIdentifier: R.nib.accountViewCell.name)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
        refreshWalletBalances()
    }

    func fetch() {
        wallets = keystore.wallets
    }

    func configure(viewModel: AccountsViewModel) {
        title = headerTitle ?? viewModel.title
    }

    func wallet(for indexPath: IndexPath) -> Wallet? {
        return viewModel.wallet(for: indexPath)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.nib.accountViewCell.name, for: indexPath) as! AccountViewCell
        cell.viewModel = getAccountViewModels(for: indexPath)
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (EtherKeystore.current != viewModel.wallet(for: indexPath) || viewModel.isLastWallet)
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

    func confirmDelete(wallet: Wallet) {
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

    func delete(wallet: Wallet) {
        navigationController?.displayLoading(text: NSLocalizedString("Deleting", value: "Deleting", comment: ""))
        keystore.delete(wallet: wallet) { [weak self] result in
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

    private func refreshWalletBalances() {
       let addresses = wallets.compactMap { $0.address }
       var counter = 0
       for address in addresses {
            balanceCoordinator.getEthBalance(for: address, completion: { [weak self] (result) in
                self?.balances[address] = result.value
                counter += 1
                if counter == addresses.count {
                    self?.tableView.reloadData()
                }
            })
        }
    }

    private func getAccountViewModels(for path: IndexPath) -> AccountViewModel {
        let account = self.wallet(for: path)! // Avoid force unwrap
        let balance = self.balances[account.address].flatMap { $0 }
        let model = AccountViewModel(server: config.server, wallet: account, current: EtherKeystore.current, walletBalance: balance)
        return model
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AccountsViewController: AccountViewCellDelegate {
    func accountViewCell(_ cell: AccountViewCell, didTapInfoViewForAccount account: Wallet) {
        self.delegate?.didSelectInfoForAccount(account: account, sender: cell.infoButton, in: self)
    }
}
