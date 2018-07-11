// Copyright DApps Platform Inc. All rights reserved.

import UIKit

class WalletsViewController: UITableViewController {

    let keystore: Keystore

    lazy var viewModel: WalletsViewModel = {
        return WalletsViewModel(keystore: keystore)
    }()

    init(keystore: Keystore) {
        self.keystore = keystore

        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
        tableView.register(R.nib.walletTableViewCell(), forCellReuseIdentifier: R.nib.walletTableViewCell.name)

        navigationItem.title = viewModel.title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.walletTableViewCell.name, for: indexPath) as! WalletTableViewCell
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
