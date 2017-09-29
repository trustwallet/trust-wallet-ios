// Copyright SIX DAY LLC. All rights reserved.

import UIKit

protocol AccountsViewControllerDelegate: class {
    func didSelectAccount(account: Account, in viewController: AccountsViewController)
    func didDeleteAccount(account: Account, in viewController: AccountsViewController)
}

class AccountsViewController: UITableViewController {

    weak var delegate: AccountsViewControllerDelegate?
    var allowsAccountDeletion: Bool = false

    var headerTitle: String?

    var viewModel: AccountsViewModel {
        return AccountsViewModel(
            accounts: accounts
        )
    }

    var hasAccounts: Bool {
        return !accounts.isEmpty
    }

    var accounts: [Account] = [] {
        didSet {
            tableView.reloadData()
            configure(viewModel: viewModel)
        }
    }

    private lazy var keystore = EtherKeystore()

    init() {
        super.init(style: .grouped)
        fetch()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        fetch()
    }

    func fetch() {
        accounts = keystore.accounts.map {
            Account(address: Address(address: $0.address.address))
        }
    }

    func configure(viewModel: AccountsViewModel) {
        title = headerTitle ?? viewModel.title
    }

    func account(for indexPath: IndexPath) -> Account {
        return viewModel.accounts[indexPath.row]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.accounts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let account = self.account(for: indexPath)
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = account.address.address
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return allowsAccountDeletion
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

    func confirmDelete(account: Account) {
        let askController = UIAlertController.askPassword(
            title: "Please enter your password to delete you account",
            message: "Make sure you export your account before deleting"
        ) { result in
            switch result {
            case .success(let password):
                self.delete(account: account, password: password)
            case .failure: break
            }
        }
        present(askController, animated: true, completion: nil)
    }

    func delete(account: Account, password: String) {
        let result = self.keystore.delete(account: account, password: password)
        switch result {
        case .success:
            self.fetch()
            self.delegate?.didDeleteAccount(account: account, in: self)
        case .failure(let error):
            self.displayError(error: error)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
