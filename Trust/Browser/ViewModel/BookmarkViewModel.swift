// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct BookmarkViewModel {
    let bookmarks: [Bookmark]
    init(bookmarks: [Bookmark]) {
        self.bookmarks = bookmarks
    }
    
    var title: String {
        return NSLocalizedString("browser.bookmarks.title", value: "Bookmarks", comment: "")
    }
}
