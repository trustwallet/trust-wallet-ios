// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StatefulViewController
import RealmSwift

protocol NonFungibleTokensViewControllerDelegate: class {
    func didSelectToken(_ token: NonFungibleTokenObject)
    func didPressDiscover()
}

class NonFungibleTokensViewController: UIViewController {

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
        tableView.backgroundColor = .white
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
        errorView = ErrorView(onRetry: { [weak self] in
            self?.fetch()
        })
        loadingView = LoadingView()
        emptyView = EmptyView(
            title: NSLocalizedString("emptyView.noNonTokens.label.title", value: "No Collectibles Found", comment: ""),
            actionTitle: NSLocalizedString("collectibles.discover.label.title", value: "Discover", comment: ""),
            onRetry: { [weak self] in
                self?.delegate?.didPressDiscover()
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
                self?.endLoading()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                var insertIndexSet = IndexSet()
                insertions.forEach { insertIndexSet.insert($0) }
                tableView.insertSections(insertIndexSet, with: insertions.count == 1 ? .top : .none)
                var deleteIndexSet = IndexSet()
                deletions.forEach { deleteIndexSet.insert($0) }
                tableView.deleteSections(deleteIndexSet, with: .none)
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

        fetch()
    }

    @objc func pullToRefresh() {
        refreshControl.beginRefreshing()
        fetch()
    }

    func fetch() {
        startLoading()
        viewModel.fetchAssets { state in
            if state {
                self.endLoading()
            }
        }
    }

    fileprivate func hederView(for section: Int) -> UIView {
        let container = UIView()
        container.backgroundColor = viewModel.headerBackgroundColor
        let title = UILabel()
        title.text = viewModel.title(for: section)
        title.sizeToFit()
        title.textColor = viewModel.headerTitleTextColor
        title.font = viewModel.headerTitleFont
        container.addSubview(title)
        title.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            title.centerXAnchor.constraint(equalTo: container.centerXAnchor, constant: 0.0),
            title.centerYAnchor.constraint(equalTo: container.centerYAnchor, constant: 0.0),
            title.leftAnchor.constraint(equalTo: container.leftAnchor, constant: 20.0),
        ])
        return container
    }
}

extension NonFungibleTokensViewController: StatefulViewController {
    func hasContent() -> Bool {
        return viewModel.hasContent
    }
}

extension NonFungibleTokensViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.didSelectToken(viewModel.token(for: indexPath))
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension NonFungibleTokensViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: R.nib.nonFungibleTokenViewCell.name, for: indexPath) as! NonFungibleTokenViewCell
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
        return StyleLayout.TableView.heightForHeaderInSection
    }
}
