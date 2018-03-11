// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

struct BookmarksViewModel {

    let bookmarksStore: BookmarksStore
    let bookmarks: [Bookmark]

    init(
        bookmarksStore: BookmarksStore
    ) {
        self.bookmarksStore = bookmarksStore
        self.bookmarks = Array(bookmarksStore.bookmarks)
    }

    var hasBookmarks: Bool {
        return !bookmarks.isEmpty
    }

    var title: String {
        return NSLocalizedString("browser.bookmarks.title", value: "Bookmarks", comment: "")
    }

    func bookmark(for indexPath: IndexPath) -> Bookmark {
        return bookmarks[indexPath.row]
    }

    func delete(bookmark: Bookmark) {
        bookmarksStore.delete(bookmarks: [bookmark])
    }
}
