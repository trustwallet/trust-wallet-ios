// Copyright DApps Platform Inc. All rights reserved.

import Foundation
import RealmSwift

final class BookmarksStore {
    var bookmarks: Results<Bookmark> {
        return realm.objects(Bookmark.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
    }
    let realm: Realm
    init(
        realm: Realm
    ) {
        self.realm = realm
    }
    func add(bookmarks: [Bookmark]) {
        realm.beginWrite()
        realm.add(bookmarks, update: true)
        try! realm.commitWrite()
    }
    func delete(bookmarks: [Bookmark]) {
        realm.beginWrite()
        realm.delete(bookmarks)
        try! realm.commitWrite()
    }
}
