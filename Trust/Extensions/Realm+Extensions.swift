// Copyright DApps Platform Inc. All rights reserved.

import RealmSwift

extension Realm {

    static let bacgroundQueue = DispatchQueue(label: "Realm",qos: .utility)

    func writeAsync<T: ThreadConfined>(obj: T, errorHandler: @escaping ((_ error: Swift.Error) -> Void) = { _ in return }, block: @escaping ((Realm, T?) -> Void)) {
        let wrappedObj = ThreadSafeReference(to: obj)
        let config = self.configuration
        DispatchQueue(label: "background").async {
            autoreleasepool {
                do {
                    let realm = try Realm(configuration: config)
                    let obj = realm.resolve(wrappedObj)

                    try realm.write {
                        block(realm, obj)
                    }
                } catch {
                    errorHandler(error)
                }
            }
        }
    }

    func backgroundInstance(_ block: @escaping (Realm) -> Void, errorHandler: @escaping ((_ error: Swift.Error) -> Void) = { _ in return }) {
        Realm.bacgroundQueue.async {
            do {
                block(try Realm(configuration: self.configuration))
            } catch(let error) {
                errorHandler(error)
            }
        }
    }
}
