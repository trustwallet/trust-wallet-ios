// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StatefulViewController
import RealmSwift

class NonFungibleTokensViewController: UIViewController {
    fileprivate var viewModel: NonFungibleTokenViewModel
    let tableView: UITableView
    let refreshControl = UIRefreshControl()
    private let trustProvider = TrustProviderFactory.makeProvider()

    init(
        viewModel: NonFungibleTokenViewModel
    ) {
        self.viewModel = viewModel
        self.tableView = UITableView(frame: .zero, style: .plain)
        super.init(nibName: nil, bundle: nil)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = .white
        view.addSubview(tableView)
        tableView.register(NonFungibleTokenViewCell.self, forCellReuseIdentifier: NonFungibleTokenViewCell.identifier)
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
        tokensObservation()
    }

    private func tokensObservation() {
        viewModel.setTokenObservation { [weak self] (changes: RealmCollectionChange) in
            guard let strongSelf = self else { return }
            let tableView = strongSelf.tableView
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map { IndexPath(row: $0, section: 0) },
                                     with: .automatic)
                for row in modifications {
                    let indexPath = IndexPath(row: row, section: 0)
                    let model = strongSelf.viewModel.cellViewModel(for: indexPath)
                    if let cell = tableView.cellForRow(at: indexPath) as? NonFungibleTokenViewCell {
                        cell.configure(viewModel: model)
                    }
                }
                tableView.endUpdates()
                self?.endLoading()
            case .error(let error):
                self?.endLoading(animated: true, error: error, completion: nil)
            }
            if strongSelf.refreshControl.isRefreshing {
                strongSelf.refreshControl.endRefreshing()
            }
        }
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
        fetch()
    }

    @objc func fetch() {
        startLoading()
        trustProvider.request(.assets(address: viewModel.address.description)) { [weak self] result in
            guard let `self` = self else { return }
            switch result {
            case .success(let response):
                do {
                    let tokens = try response.map(ArrayResponse<AssetCategory>.self).docs
                    // TODO: Implement storage
                    //let assets: [[NonFungibleTokenObject]] = tokens.map { .from(category: $0) }
                    //viewModel.storage.add(tokens: assets)
                } catch {
                    self.endLoading(error: error)
                }
                self.endLoading()
            case .failure(let error):
                self.endLoading(error: error)
            }
        }
    }
}

extension NonFungibleTokensViewController: StatefulViewController {
    func hasContent() -> Bool {
        return viewModel.hasContent
    }
}

extension NonFungibleTokensViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

extension NonFungibleTokensViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NonFungibleTokenViewCell.identifier, for: indexPath) as! NonFungibleTokenViewCell
        cell.configure(viewModel: viewModel.cellViewModel(for: indexPath))
        return cell
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tokens.count
    }
}
