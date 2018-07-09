// Copyright DApps Platform Inc. All rights reserved.

import UIKit
import WebKit
import PromiseKit
import KeychainSwift

enum CookiesStoreError: LocalizedError {
    case empty
}

final class CookiesStore {

    private static let webKitStorage = WKWebsiteDataStore.default()
    private static let httpCookieStorage = HTTPCookieStorage.shared
    private static let keychain = KeychainSwift(keyPrefix: Constants.keychainKeyPrefix)

    private static let cookiesKey = "cookies"

    static func save() {
        firstly {
            fetchCookies()
        }.done { cookies in
            save(cookies: cookies)
        }
    }

    static func load() {
        guard let encodedData = keychain.getData(cookiesKey), let decodedArray = NSKeyedUnarchiver.unarchiveObject(with: encodedData) as? [HTTPCookie] else { return }
        decodedArray.forEach { cookie in
            if #available(iOS 11.0, *) {
                webKitStorage.httpCookieStore.setCookie(cookie, completionHandler: nil)
            } else {
                httpCookieStorage.setCookie(cookie)
            }
        }
    }

    static func delete() {
        keychain.delete(cookiesKey)
    }

    private static func save(cookies: [HTTPCookie]) {
        let data = NSKeyedArchiver.archivedData(withRootObject: cookies)
        keychain.set(data, forKey: cookiesKey)
    }

    private static func fetchCookies() -> Promise<[HTTPCookie]> {
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
