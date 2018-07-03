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
    let ensManager: ENSManager
    weak var delegate: AccountsViewControllerDelegate?
    var viewModel: AccountsViewModel {
        return AccountsViewModel(
            wallets: accounts
        )
    }
    var hasWallets: Bool {
        return !accounts.isEmpty
    }

    var wallets: [Wallet] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    var accounts: [WalletInfo] {
        return wallets.map {
            return WalletInfo(wallet: $0)
        }
    }

    private var balances: [Address: Balance?] = [:]
    private var addrNames: [Address: String] = [:]
    private let keystore: Keystore
    private let walletStorage: WalletStorage
    private let balanceCoordinator: TokensBalanceService
    private let config = Config()

    init(
        keystore: Keystore,
        walletStorage: WalletStorage,
        balanceCoordinator: TokensBalanceService,
        ensManager: ENSManager
    ) {
        self.keystore = keystore
        self.walletStorage = walletStorage
        self.balanceCoordinator = balanceCoordinator
        self.ensManager = ensManager
        super.init(style: .grouped)
        fetch()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(R.nib.accountViewCell(), forCellReuseIdentifier: R.nib.accountViewCell.name)
        configure(viewModel: viewModel)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
        refreshWalletBalances()
        refreshENSNames()
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
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.nib.accountViewCell.name, for: indexPath) as! AccountViewCell
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
        navigationController?.displayLoading(text: NSLocalizedString("Deleting", value: "Deleting", comment: ""))
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

    private func refreshWalletBalances() {
       let addresses = accounts.compactMap { $0.wallet.address }
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

    private func refreshENSNames() {
        let addresses = accounts.compactMap { $0.wallet.address }
        let promises =  addresses.map { ensManager.lookup(address: $0) }
        _ = when(fulfilled: promises).done { [weak self] names in
            for (index, name) in names.enumerated() {
                self?.addrNames[addresses[index]] = name
            }
            self?.tableView.reloadData()
        }.catch { error in
            print(error)
        }
    }

    private func getAccountViewModels(for path: IndexPath) -> AccountViewModel {
        let account = self.wallet(for: path)! // Avoid force unwrap
        let balance = self.balances[account.wallet.address].flatMap { $0 }
        let ensName = self.addrNames[account.wallet.address] ?? ""
        let model = AccountViewModel(server: config.server, wallet: account, current: EtherKeystore.current, walletBalance: balance, ensName: ensName)
        return model
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
