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
        return bookmark.url
    }
    var title: String {
        return bookmark.title
    }
    var imageURL: URL? {
        guard let host = bookmark.linkURL?.host else {
            return URL(string: "https://api.statvoo.com/favicon/?url=www.trustwalletapp.com")
        }
        return URL(string: "https://api.statvoo.com/favicon/?url=\(host)")
    }
}
