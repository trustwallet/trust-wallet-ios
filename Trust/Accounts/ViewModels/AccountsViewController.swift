// Copyright SIX DAY LLC. All rights reserved.

import TrustKeystore
import UIKit

protocol AccountsViewControllerDelegate: class {
    func didSelectAccount(account: Wallet, in viewController: AccountsViewController)
    func didDeleteAccount(account: Wallet, in viewController: AccountsViewController)
    func didSelectInfoForAccount(account: Wallet, sender: UIView, in viewController: AccountsViewController)
}

class AccountsViewController: UITableViewController {

    weak var delegate: AccountsViewControllerDelegate?
    var allowsAccountDeletion: Bool = false

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

    private let keystore: Keystore

    init(
        keystore: Keystore
    ) {
        self.keystore = keystore
        super.init(style: .grouped)
        fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetch()
    }

    func fetch() {
        wallets = keystore.wallets
    }

    func configure(viewModel: AccountsViewModel) {
        title = headerTitle ?? viewModel.title
    }

    func account(for indexPath: IndexPath) -> Wallet {
        return viewModel.wallets[indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.wallets.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let account = self.account(for: indexPath)
        let cell = AccountViewCell(style: .default, reuseIdentifier: AccountViewCell.identifier)
        cell.viewModel = AccountViewModel(wallet: account, current: EtherKeystore.current)
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowsAccountDeletion && (EtherKeystore.current != viewModel.wallets[indexPath.row] || viewModel.wallets.count == 1)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            let account = self.account(for: indexPath)
            confirmDelete(account: account)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let account = self.account(for: indexPath)
        delegate?.didSelectAccount(account: account, in: self)
    }

    func confirmDelete(account: Wallet) {
        confirm(
            title: "Are you sure you would like to delete this wallet?",
            message: "Make sure you have backup of your wallet",
            okTitle: "Delete",
            okStyle: .destructive
        ) { result in
            switch result {
            case .success:
                self.delete(account: account)
            case .failure: break
            }
        }
    }

    func delete(account: Wallet) {
        navigationController?.displayLoading(text: NSLocalizedString("Deleting", value: "Deleting", comment: ""))
        keystore.delete(wallet: account) { [weak self] result in
            guard let `self` = self else { return }
            self.navigationController?.hideLoading()
            switch result {
            case .success:
                self.fetch()
                self.delegate?.didDeleteAccount(account: account, in: self)
            case .failure(let error):
                self.displayError(error: error)
            }
        }
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
