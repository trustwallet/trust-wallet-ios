// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

struct BookmarksViewModel {
    
    var store: BookmarksStore
    
    let bookmarks: [Bookmark]

    init() {
        self.store = BookmarksStore(realm: try! Realm())
        self.bookmarks = Array(store.bookmarks)
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
}
