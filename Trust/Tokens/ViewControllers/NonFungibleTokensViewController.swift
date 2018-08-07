// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import StatefulViewController
import RealmSwift
import PromiseKit

protocol NonFungibleTokensViewControllerDelegate: class {
    func didPressDiscover()
    func didPress(token: CollectibleTokenObject, with bacground: UIColor)
}

final class NonFungibleTokensViewController: UIViewController {

    private var viewModel: NonFungibleTokenViewModel
    let tableView: UITableView
    let refreshControl = UIRefreshControl()

    weak var delegate: NonFungibleTokensViewControllerDelegate?

    init(
        viewModel: NonFungibleTokenViewModel
    ) {
        self.viewModel = viewModel
        self.tableView = UITableView(frame: .zero, style: .grouped)
        super.init(nibName: nil, bundle: nil)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = viewModel.tableViewBacgroundColor
        view.addSubview(tableView)
        tableView.register(R.nib.nonFungibleTokenViewCell(), forCellReuseIdentifier: R.nib.nonFungibleTokenViewCell.name)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        errorView = ErrorView(
            onRetry: { [weak self] in
                self?.fetch()
            }
        )
        loadingView = LoadingView()
        emptyView = EmptyView(
            title: NSLocalizedString("emptyView.noNonTokens.label.title", value: "No Collectibles Found", comment: ""),
            onRetry: { [weak self] in
                self?.fetch()
            }
        )
        title = viewModel.title
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.applyTintAdjustment()

        fetch()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.invalidateTokensObservation()
    }

    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch()
    }

    func fetch() {
        startLoading()
        firstly {
            viewModel.fetchAssets()
        }.done { [weak self] _ in
            self?.endLoading()
            self?.tableView.reloadData()
        }.ensure { [weak self] in
            self?.refreshControl.endRefreshing()
        }.catch { [weak self] error in
            self?.endLoading(animated: true, error: error, completion: nil)
        }
    }

    fileprivate func hederView(for section: Int) -> UIView {
        return SectionHeader(fillColor: viewModel.tableViewBacgroundColor, borderColor: UIColor.clear, title: viewModel.title(for: section), textColor: viewModel.headerTitleTextColor, textFont: viewModel.headerTitleFont)
    }
}

extension NonFungibleTokensViewController: StatefulViewController {
    func hasContent() -> Bool {
        return viewModel.hasContent
    }
}

extension NonFungibleTokensViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewModel.cellHeight
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
}

extension NonFungibleTokensViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.nonFungibleTokenViewCell.name, for: indexPath) as! NonFungibleTokenViewCell
        cell.configure(viewModel: viewModel.cellViewModel(for: indexPath))
        cell.delegate = delegate
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return hederView(for: section)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return StyleLayout.CollectibleView.heightForHeaderInSection
    }
}
