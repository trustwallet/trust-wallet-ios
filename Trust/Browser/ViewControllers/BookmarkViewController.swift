// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit
import Kingfisher

protocol BookmarkViewControllerDelegate: class {
    func didSelectBookmark(_ bookmark: Bookmark, in viewController: BookmarkViewController)
}

class BookmarkViewController: UITableViewController {
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
    }

    func fetch() {
        bookmarks = Array(store.bookmarks)
    }

    func configure(viewModel: BookmarksViewModel) {
        title = viewModel.title
    }

    func bookmark(for indexPath: IndexPath) -> Bookmark {
        return viewModel.bookmarks[indexPath.row]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookmarks.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> BookmarkViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: R.nib.bookmarkViewCell.name, for: indexPath) as! BookmarkViewCell
        cell.viewModel = BookmarkViewModel(bookmark: viewModel.bookmarks[indexPath.row])
        cell.faviconImage?.kf.setImage(
            with: cell.viewModel?.imageURL,
            placeholder: R.image.launch_screen_logo()
        )
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let bookmark = self.bookmark(for: indexPath)
            confirmDelete(bookmark: bookmark, index: indexPath)
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let bookmark = self.bookmark(for: indexPath)
        delegate?.didSelectBookmark(bookmark, in: self)
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
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
