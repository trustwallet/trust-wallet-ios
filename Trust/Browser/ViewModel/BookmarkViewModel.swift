// Copyright SIX DAY LLC. All rights reserved.

import Foundation

struct BookmarkViewModel {
    let bookmark: Bookmark
    init(
        bookmark: Bookmark
    ) {
        self.bookmark = bookmark
    }
    var url: String {
        return self.bookmark.url
    }
    var title: String {
        return self.bookmark.title
    }
    var imageURL: URL? {
        return URL(string: "\(bookmark.url)favicon.ico")
    }
}
