// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift

final class Bookmark: Object {
    @objc dynamic var url: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var createdAt: Date = Date()

    convenience init(
        url: String = "",
        title: String = ""
    ) {
        self.init()
        self.url = url
        self.title = title
    }

    var linkURL: URL? {
        return URL(string: url)
    }

    override class func primaryKey() -> String? {
        return "id"
    }
}
