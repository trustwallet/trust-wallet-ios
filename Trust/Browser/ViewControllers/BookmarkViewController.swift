// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit
import StatefulViewController

protocol BookmarkViewControllerDelegate: class {
    func didSelectBookmark(_ bookmark: Bookmark, in viewController: BookmarkViewController)
}

final class BookmarkViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .plain)

    weak var delegate: BookmarkViewControllerDelegate?
    private let bookmarksStore: BookmarksStore

    lazy var viewModel: BookmarksViewModel = {
        return BookmarksViewModel(bookmarksStore: bookmarksStore)
    }()

    init(
        bookmarksStore: BookmarksStore
    ) {
        self.bookmarksStore = bookmarksStore

        super.init(nibName: nil, bundle: nil)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 60
        tableView.register(R.nib.bookmarkViewCell(), forCellReuseIdentifier: R.nib.bookmarkViewCell.name)
        view.addSubview(tableView)
        emptyView = EmptyView(title: NSLocalizedString("bookmarks.noBookmarks.label.title", value: "No bookmarks yet!", comment: ""))

        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupInitialViewState()

        fetch()
    }

    func fetch() {
        tableView.reloadData()
    }

    func confirmDelete(bookmark: Bookmark, index: IndexPath) {
        confirm(title: NSLocalizedString("browser.bookmarks.confirm.delete.title", value: "Are you sure you would like to delete this bookmark?", comment: ""),
                okTitle: R.string.localizable.delete(),
                okStyle: .destructive) { result in
                    switch result {
                    case .success:
                        self.delete(bookmark: bookmark, index: index)
                    case .failure: break
                    }
        }
    }

    func delete(bookmark: Bookmark, index: IndexPath) {
        viewModel.delete(bookmark: bookmark)
        tableView.deleteRows(at: [index], with: .automatic)
        transitionViewStates()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension BookmarkViewController: StatefulViewController {
    func hasContent() -> Bool {
        return viewModel.hasBookmarks
    }
}

extension BookmarkViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.nib.bookmarkViewCell.name, for: indexPath) as! BookmarkViewCell
        cell.viewModel = BookmarkViewModel(bookmark: viewModel.bookmark(for: indexPath))
        return cell
    }
}

extension BookmarkViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookmark = viewModel.bookmark(for: indexPath)
            confirmDelete(bookmark: bookmark, index: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bookmark = viewModel.bookmark(for: indexPath)
        delegate?.didSelectBookmark(bookmark, in: self)
    }
}
