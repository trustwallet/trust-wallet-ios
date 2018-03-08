// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct BookmarksViewModel {
    let bookmarks: [Bookmark]
    init(bookmarks: [Bookmark]) {
        self.bookmarks = bookmarks
    }

    var hasBookmarks: Bool {
        return !bookmarks.isEmpty
    }

    var title: String {
        return NSLocalizedString("browser.bookmarks.title", value: "Bookmarks", comment: "")
    }
}
