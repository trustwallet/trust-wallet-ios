// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

struct BookmarksViewModel {

    let bookmarksStore: BookmarksStore

    init(
        bookmarksStore: BookmarksStore
    ) {
        self.bookmarksStore = bookmarksStore
    }

    var hasBookmarks: Bool {
        return !bookmarksStore.bookmarks.isEmpty
    }

    var numberOfRows: Int {
        return bookmarksStore.bookmarks.count
    }

    var title: String {
        return NSLocalizedString("browser.bookmarks.title", value: "Bookmarks", comment: "")
    }

    func bookmark(for indexPath: IndexPath) -> Bookmark {
        return bookmarksStore.bookmarks[indexPath.row]
    }

    func delete(bookmark: Bookmark) {
        bookmarksStore.delete(bookmarks: [bookmark])
    }
}
