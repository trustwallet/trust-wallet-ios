// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import TrustKeystore

protocol WalletsViewControllerDelegate: class {
    func didSelect(wallet: WalletInfo, account: Account, in controller: WalletsViewController)
    func didDeleteAccount(account: WalletInfo, in viewController: WalletsViewController)
    func didSelectForInfo(wallet: WalletInfo, account: Account, in controller: WalletsViewController)
}

class WalletsViewController: UITableViewController {

    let keystore: Keystore
    lazy var viewModel: WalletsViewModel = {
        let model = WalletsViewModel(keystore: keystore)
        model.delegate = self
        return model
    }()
    weak var delegate: WalletsViewControllerDelegate?

    init(keystore: Keystore) {
        self.keystore = keystore
        super.init(style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = StyleLayout.TableView.separatorColor
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.walletViewCell(), forCellReuseIdentifier: R.nib.walletViewCell.name)
        navigationItem.title = viewModel.title
        tableView.tableFooterView = UIView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
    }

    func fetch() {
        viewModel.fetchBalances()
        viewModel.refresh()
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.walletViewCell.name, for: indexPath) as! WalletViewCell
        cell.viewModel = viewModel.cellViewModel(for: indexPath)
        cell.delegate = self
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return viewModel.canEditRowAt(for: indexPath)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCellEditingStyle.delete {
            confirmDelete(wallet: viewModel.cellViewModel(for: indexPath).wallet)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = self.viewModel.cellViewModel(for: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(wallet: viewModel.wallet, account: viewModel.account, in: self)
    }

    func confirmDelete(wallet: WalletInfo) {
        confirm(
            title: NSLocalizedString("accounts.confirm.delete.title", value: "Are you sure you would like to delete this wallet?", comment: ""),
            message: NSLocalizedString("accounts.confirm.delete.message", value: "Make sure you have backup of your wallet.", comment: ""),
            okTitle: R.string.localizable.delete(),
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
        keystore.delete(wallet: wallet) { [weak self] result in
            guard let `self` = self else { return }
            self.navigationController?.hideLoading()
            switch result {
            case .success:
                self.delegate?.didDeleteAccount(account: wallet, in: self)
            case .failure(let error):
                self.displayError(error: error)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension WalletsViewController: WalletViewCellDelegate {
    func didPress(viewModel: WalletAccountViewModel, in cell: WalletViewCell) {
        delegate?.didSelectForInfo(wallet: viewModel.wallet, account: viewModel.account, in: self)
    }
}

extension WalletsViewController: WalletsViewModelProtocol {
    func update() {
        viewModel.refresh()
        tableView.reloadData()
    }
}
