// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class BookmarksStore {
    var bookmarks: Results<BookmarkObject> {
        return realm.objects(BookmarkObject.self)
    }
    let realm: Realm
    init(
        realm: Realm
    ) {
        self.realm = realm
    }
    func add(bookmarks: [BookmarkObject]) {
        realm.beginWrite()
        realm.add(bookmarks, update: true)
        try! realm.commitWrite()
    }
    func delete(bookmarks: [BookmarkObject]) {
        realm.beginWrite()
        realm.delete(bookmarks)
        try! realm.commitWrite()
    }
}
