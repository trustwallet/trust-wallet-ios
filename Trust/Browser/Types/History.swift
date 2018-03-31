// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class History: Object {
    @objc dynamic var url: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var visitCount: Int = 0
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var updatedAt: Date = Date()

    convenience init(url: String, title: String) {
        self.init()
        self.url = url
        self.title = title
    }

    var URL: URL? {
        return Foundation.URL(string: url)
    }

    override class func primaryKey() -> String? {
        return "url"
    }
}
