// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StatefulViewController
import RealmSwift

class NonFungibleTokensViewController: UIViewController {

    fileprivate var viewModel: NonFungibleTokenViewModel
    
    let tableView: UITableView

    let refreshControl = UIRefreshControl()

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
        tableView.backgroundColor = .white
        tableView.allowsSelection = false
        view.addSubview(tableView)
        tableView.register(R.nib.nonFungibleTokenViewCell(), forCellReuseIdentifier: NonFungibleTokenViewCell.identifier)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        tableView.addSubview(refreshControl)
        errorView = ErrorView(onRetry: { [weak self] in
            self?.fetch()
        })
        loadingView = LoadingView()
        emptyView = EmptyView(
            title: NSLocalizedString("emptyView.noNonTokens.label.title", value: "You haven't received any non fungible tokens yet!", comment: ""),
            onRetry: { [weak self] in
                self?.fetch()
        })
        tokensObservation()
        fetch()
    }

    private func tokensObservation() {
        viewModel.setTokenObservation { [weak self] (changes: RealmCollectionChange) in
            guard let strongSelf = self else { return }
            let tableView = strongSelf.tableView
            switch changes {
            case .initial:
                tableView.reloadData()
                self?.endLoading()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                var insertIndexSet = IndexSet()
                insertions.forEach { insertIndexSet.insert($0) }
                tableView.insertSections(insertIndexSet, with: insertions.count == 1 ? .top : .automatic)
                var deleteIndexSet = IndexSet()
                deletions.forEach { deleteIndexSet.insert($0) }
                tableView.deleteSections(deleteIndexSet, with: .automatic)
                var updateIndexSet = IndexSet()
                modifications.forEach { updateIndexSet.insert($0) }
                tableView.reloadSections(updateIndexSet, with: .none)
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

    func fetch() {
        startLoading()
        viewModel.fetchAssets()
    }

    fileprivate func hederView(for section: Int) -> UIView {
        let conteiner = UIView()
        conteiner.backgroundColor = viewModel.headerBackgroundColor
        let title = UILabel()
        title.text = viewModel.title(for: section)
        title.sizeToFit()
        title.textColor = viewModel.headerTitleTextColor
        title.font = viewModel.headerTitleFont
        conteiner.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        let horConstraint = NSLayoutConstraint(item: title, attribute: .centerX, relatedBy: .equal, toItem: conteiner, attribute: .centerX, multiplier: 1.0, constant: 0.0)
        let verConstraint = NSLayoutConstraint(item: title, attribute: .centerY, relatedBy: .equal, toItem: conteiner, attribute: .centerY, multiplier: 1.0, constant: 0.0)
        let leftConstraint = NSLayoutConstraint(item: title, attribute: .left, relatedBy: .equal, toItem: conteiner, attribute: .left, multiplier: 1.0, constant: 20.0)
        conteiner.addConstraints([horConstraint, verConstraint, leftConstraint])
        return conteiner
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
        return viewModel.numberOfItems(in: section)
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return hederView(for: section)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
