// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class HistoryStore {
    var histories: Results<History> {
        return realm.objects(History.self)
            .sorted(byKeyPath: "createdAt", ascending: false)
    }
    let realm: Realm
    init(realm: Realm) {
        self.realm = realm
    }

    lazy var ignoreSet: Set<String> = {
        let set = Set<String>([
            Constants.dappsBrowserURL,
        ])
        return set
    }()

    func record(url: URL, title: String) {
        guard !ignoreSet.contains(url.absoluteString) else {
            return
        }
        let history = History(url: url.absoluteString, title: title)
        add(histories: [history])
    }

    func add(histories: [History]) {

        do {
            try realm.write {
                realm.add(histories, update: true)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func delete(histories: [History]) {
        do {
            try realm.write {
                realm.delete(histories)
            }
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
