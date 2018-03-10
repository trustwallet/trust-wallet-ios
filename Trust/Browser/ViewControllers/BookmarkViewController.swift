// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Kingfisher
import StatefulViewController

protocol BookmarkViewControllerDelegate: class {
    func didSelectBookmark(_ bookmark: Bookmark, in viewController: BookmarkViewController)
}

class BookmarkViewController: UIViewController {

    let tableView = UITableView(frame: .zero, style: .plain)

    weak var delegate: BookmarkViewControllerDelegate?

    var viewModel: BookmarksViewModel {
        return BookmarksViewModel(
            bookmarks: bookmarks
        )
    }

    var bookmarks: [Bookmark] = [] {
        didSet {
            tableView.reloadData()
            configure(viewModel: viewModel)
        }
    }

    private var store: BookmarksStore

    init(
        store: BookmarksStore
    ) {
        self.store = store
        super.init(nibName: nil, bundle: nil)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .white
        tableView.separatorStyle = .singleLine
        tableView.rowHeight = 55
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        emptyView = BookmarksEmptyView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 55
        tableView.register(R.nib.bookmarkViewCell(), forCellReuseIdentifier: R.nib.bookmarkViewCell.name)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
        setupInitialViewState()
    }

    func fetch() {
        bookmarks = Array(store.bookmarks)
    }

    func configure(viewModel: BookmarksViewModel) {
        title = viewModel.title
    }

    func bookmark(for indexPath: IndexPath) -> Bookmark {
        return bookmarks[indexPath.row]
    }

    func confirmDelete(bookmark: Bookmark, index: IndexPath) {
        confirm(title: NSLocalizedString("browser.bookmarks.confirm.delete.title", value: "Are you sure you would like to delete this bookmark?", comment: ""),
                okTitle: NSLocalizedString("Delete", value: "Delete", comment: ""),
                okStyle: .destructive) { result in
                    switch result {
                    case .success:
                        self.delete(bookmark: bookmark, index: index)
                    case .failure: break
                    }
        }
    }

    func delete(bookmark: Bookmark, index: IndexPath) {
        store.delete(bookmarks: [bookmark])
        fetch()
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
        return viewModel.bookmarks.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.nib.bookmarkViewCell.name, for: indexPath) as! BookmarkViewCell
        cell.viewModel = BookmarkViewModel(bookmark: viewModel.bookmarks[indexPath.row])
        cell.faviconImage?.kf.setImage(
            with: cell.viewModel?.imageURL,
            placeholder: R.image.launch_screen_logo()
        )
        return cell
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return StyleLayout.TableView.heightForHeaderInSection
    }
}

extension BookmarkViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookmark = self.bookmark(for: indexPath)
            confirmDelete(bookmark: bookmark, index: indexPath)
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let bookmark = self.bookmark(for: indexPath)
        delegate?.didSelectBookmark(bookmark, in: self)
    }
}
