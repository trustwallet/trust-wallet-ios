// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct BookmarkViewModel {
    let bookmarks: [BookmarkObject]
    init(bookmarks: [BookmarkObject]) {
        self.bookmarks = bookmarks
    }
    
    var title: String {
        return NSLocalizedString("browser.bookmarks.title", value: "Bookmarks", comment: "")
    }
}
