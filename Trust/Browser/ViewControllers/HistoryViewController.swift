// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import StatefulViewController

protocol HistoryViewControllerDelegate: class {
    func didSelect(history: History, in controller: HistoryViewController)
}

class HistoryViewController: UIViewController {

    let store: HistoryStore
    let tableView = UITableView(frame: .zero, style: .plain)
    lazy var viewModel: HistoriesViewModel = {
        return HistoriesViewModel(store: store)
    }()

    weak var delegate: HistoryViewControllerDelegate?

    init(store: HistoryStore) {
        self.store = store

        super.init(nibName: nil, bundle: nil)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 60
        tableView.register(R.nib.bookmarkViewCell(), forCellReuseIdentifier: R.nib.bookmarkViewCell.name)
        view.addSubview(tableView)
        emptyView = EmptyView(title: NSLocalizedString("history.noHistory.label.title", value: "No history yet!", comment: ""))

        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialViewState()

        fetch()
    }

    func fetch() {
        tableView.reloadData()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension HistoryViewController: StatefulViewController {
    func hasContent() -> Bool {
        return viewModel.hasContent
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.nib.bookmarkViewCell.name, for: indexPath) as! BookmarkViewCell
        cell.viewModel = HistoryViewModel(history: viewModel.item(for: indexPath))
        return cell
    }
}

extension HistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let history = viewModel.item(for: indexPath)
        delegate?.didSelect(history: history, in: self)
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let history = viewModel.item(for: indexPath)
            confirm(
                title: NSLocalizedString("Are you sure you would like to delete?", value: "Are you sure you would like to delete?", comment: ""),
                okTitle: R.string.localizable.delete(),
                okStyle: .destructive
            ) { [weak self] result in
                    switch result {
                    case .success:
                        self?.store.delete(histories: [history])
                        self?.tableView.reloadData()
                    case .failure: break
                    }
            }
        }
    }
}
