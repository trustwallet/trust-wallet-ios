// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import TrustKeystore

protocol WalletsViewControllerDelegate: class {
    func didSelect(wallet: WalletInfo, account: Account, in controller: WalletsViewController)
}

class WalletsViewController: UITableViewController {

    let keystore: Keystore
    lazy var viewModel: WalletsViewModel = {
        return WalletsViewModel(keystore: keystore)
    }()
    weak var delegate: WalletsViewControllerDelegate?

    init(keystore: Keystore) {
        self.keystore = keystore

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = 60
        tableView.register(R.nib.walletTableViewCell(), forCellReuseIdentifier: R.nib.walletTableViewCell.name)

        navigationItem.title = viewModel.title
    }

    func fetch() {
        displayLoading()
        viewModel.load { [weak self] in
            self?.tableView.reloadData()
            self?.hideLoading()
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.walletTableViewCell.name, for: indexPath) as! WalletTableViewCell
        cell.configure(for: viewModel.cellViewModel(for: indexPath))
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let title = viewModel.titleForHeader(in: section) else { return .none }
        return SectionHeader(title: title)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return viewModel.heightForHeader(in: section)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = self.viewModel.cellViewModel(for: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(wallet: viewModel.wallet, account: viewModel.account, in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
