// Copyright SIX DAY LLC. All rights reserved.

import Foundation
import RealmSwift

class HistoryStore {
    var histories: Results<History> {
        return realm.objects(History.self)
    }
    let realm: Realm
    init(realm: Realm) {
        self.realm = realm
    }

    lazy var ignoreSet: Set<String> = {
        let set = Set<String>([
            Constants.dappsBrowserURL,
            "\(Constants.dappsBrowserURL)/",
        ])
        return set
    }()

    func record(url: URL, title: String) {
        guard !ignoreSet.contains(url.absoluteString) else {
            return
        }
        let results = histories.filter(NSPredicate(format: "url = %@", url.absoluteString))
        if results.isEmpty {
            // create
            let history = History(url: url.absoluteString, title: title)
            history.visitCount += 1
            add(histories: [history])
        } else {
            let now = Date()
            do {
                realm.beginWrite()
                for history in results {
                    history.updatedAt = now
                    history.visitCount += 1
                }
                try realm.commitWrite()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }

    func add(histories: [History]) {
        do {
            realm.beginWrite()
            realm.add(histories, update: true)
            try realm.commitWrite()
        } catch let error {
            print(error.localizedDescription)
        }
    }

    func delete(histories: [History]) {
        do {
            realm.beginWrite()
            realm.delete(histories)
            try realm.commitWrite()
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
