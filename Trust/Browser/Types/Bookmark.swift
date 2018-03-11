// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class Bookmark: Object {
    @objc dynamic var url: String = ""
    @objc dynamic var title: String = ""
    @objc dynamic var id: Int = 0

    convenience init(
            url: String = "",
            title: String = ""
        ) {
        self.init()
        self.url = url
        self.title = title
        self.id = incrementID()
    }

    var linkURL: URL? {
        return URL(string: url)
    }

    override class func primaryKey() -> String? {
        return "id"
    }

    func incrementID() -> Int {
        let realm = try! Realm()
        return (realm.objects(Bookmark.self).max(ofProperty: "id") as Int? ?? 1) + 1
    }
}
