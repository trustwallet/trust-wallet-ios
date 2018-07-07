// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import UIKit

struct BookmarkViewModel: URLViewModel {

    let bookmark: Bookmark
    init(
        bookmark: Bookmark
    ) {
        self.bookmark = bookmark
    }

    var urlText: String? {
        return bookmark.linkURL?.absoluteString
    }

    var title: String {
        return bookmark.title
    }

    var imageURL: URL? {
        return Favicon.get(for: bookmark.linkURL)
    }
}
