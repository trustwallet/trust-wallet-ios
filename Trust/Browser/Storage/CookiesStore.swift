// Copyright SIX DAY LLC. All rights reserved.

import UIKit
import WebKit
import PromiseKit
import KeychainSwift

enum CookiesStoreError: LocalizedError {
    case empty
}

class CookiesStore {

    private let webKitStorage = WKWebsiteDataStore.default()
    private let httpCookieStorage = HTTPCookieStorage.shared
    private let keychain = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix)

    private var key: String

    init(sessionKey: String) {
        self.key = sessionKey
        load()
    }

    func syncCookies() {
        firstly {
            fetchCookies()
        }.done { [weak self] cookies in
            self?.save(cookies: cookies)
        }
    }

    func load() {
        guard let encodedData = keychain.getData(key), let decodedArray = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? [HTTPCookie] else { return }
        decodedArray.forEach { cookie in
            if #available(iOS 11.0, *) {
                webKitStorage.httpCookieStore.setCookie(cookie, completionHandler: nil)
            } else {
                httpCookieStorage.setCookie(cookie)
            }
        }
    }

    func delete() {
        keychain.delete(key)
    }

    private func save(cookies: [HTTPCookie]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: cookies)
        keychain.set(data, forKey: key)
    }

    private func fetchCookies() -> Promise<[HTTPCookie]> {
        return Promise { seal in
            if #available(iOS 11.0, *) {
                webKitStorage.httpCookieStore.getAllCookies { cookies in
                    seal.fulfill(cookies)
                }
            } else {
                guard let cookies = httpCookieStorage.cookies else {
                    seal.reject(CookiesStoreError.empty)
                    return
                }
                seal.fulfill(cookies)
            }
        }
    }
}
