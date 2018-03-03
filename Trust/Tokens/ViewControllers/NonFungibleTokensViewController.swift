// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StatefulViewController

class NonFungibleTokensViewController: UIViewController {
    fileprivate var viewModel: NonFungibleTokenViewModel
    let tableView: UITableView
    let refreshControl = UIRefreshControl()
    init(viewModel: NonFungibleTokenViewModel) {
        self.viewModel = viewModel
        self.tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ])
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        errorView = ErrorView(onRetry: { [weak self] in
            self?.startLoading()
        })
        loadingView = LoadingView()
        emptyView = EmptyView(
            title: NSLocalizedString("emptyView.noNonTokens.label.title", value: "You haven't received any non fungible tokens yet!", comment: ""),
            onRetry: { [weak self] in
                self?.startLoading()
        })

    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.applyTintAdjustment()
    }
    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
    }
}
extension NonFungibleTokensViewController: StatefulViewController {
    func hasContent() -> Bool {
        return true
    }
}
extension NonFungibleTokensViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
extension NonFungibleTokensViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tokens.count
    }
}
