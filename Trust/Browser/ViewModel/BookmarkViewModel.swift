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
        let host = URL(string: bookmark.url)?.host
        return URL(string: "https://api.statvoo.com/favicon/?url=\(host ?? "www.trustwalletapp.com")")
    }
}
