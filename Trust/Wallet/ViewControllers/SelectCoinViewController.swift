// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import TrustCore

protocol SelectCoinViewControllerDelegate: class {
    func didSelect(coin: Coin, in controller: SelectCoinViewController)
}

class SelectCoinViewController: UITableViewController {

    lazy var viewModel: SelectCoinsViewModel = {
        let elements = coins.map { CoinViewModel(coin: $0) }
        return SelectCoinsViewModel(elements: elements)
    }()
    let coins: [Coin]
    weak var delegate: SelectCoinViewControllerDelegate?

    init(
        coins: [Coin]
    ) {
        self.coins = coins
        super.init(style: .grouped)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.separatorColor = StyleLayout.TableView.separatorColor
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.register(R.nib.coinViewCell(), forCellReuseIdentifier: R.nib.coinViewCell.name)
        tableView.tableFooterView = UIView()
        navigationItem.title = viewModel.title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.coinViewCell.name, for: indexPath) as! CoinViewCell
        cell.configure(for: viewModel.cellViewModel(for: indexPath))
        return cell
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSection
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let viewModel = self.viewModel.cellViewModel(for: indexPath)
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.didSelect(coin: viewModel.coin, in: self)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
