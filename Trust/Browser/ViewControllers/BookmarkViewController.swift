// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import UIKit

protocol BookmarkViewControllerDelegate: class {
    func didSelectBookmark(bookmark: Bookmark, in viewController: BookmarkViewController)
}

class BookmarkViewController: UITableViewController {
    weak var delegate: BookmarkViewControllerDelegate?
    var headerTitle: String?
    var viewModel: BookmarkViewModel {
        return BookmarkViewModel(
            bookmarks: bookmarks
        )
    }
    var hasBookmarks: Bool {
        return !store.bookmarks.isEmpty
    }
    var bookmarks: [Bookmark] = [] {
        didSet {
            tableView.reloadData()
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
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetch()
    }
    func fetch() {
        bookmarks = Array(store.bookmarks)
    }
    func configure(viewModel: BookmarkViewModel) {
        title = headerTitle ?? viewModel.title
    }
    func bookmark(for indexPath: IndexPath) -> Bookmark {
        return viewModel.bookmarks[indexPath.row]
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookmarks.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = self.tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath)
        let cell = UITableViewCell()
        cell.textLabel?.text = viewModel.bookmarks[indexPath.row].title
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
        delegate?.didSelectBookmark(bookmark: bookmark, in: self)
    }
    func confirmDelete(bookmark: Bookmark, index: IndexPath) {
        confirm(title: NSLocalizedString("browser.bookmarks.confirm.delete.title", value: "Are you sure you would like to delete this bookmark?", comment: ""),
                okTitle: NSLocalizedString("browser.bookmarks.confirm.delete.okTitle", value: "Delete", comment: ""),
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
        //FIXME: How do we add an animation to this? Can't do it manually since remove() already removes it
        self.bookmarks.remove(at: index.row)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
